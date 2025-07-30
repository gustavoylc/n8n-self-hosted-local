#!/bin/sh
set -e

# Check if import should run based on environment variables
if [ "${RUN_IMPORT_ON_STARTUP:-}" != "" ] && [ "${RUN_IMPORT_ON_STARTUP}" = "false" ]; then
    echo "RUN_IMPORT_ON_STARTUP is false. Skipping import."
    exit 0
fi

echo "Starting n8n workflow validation and import process..."

ERROR_DIR=/import/workflows/with_error
COMPLETED_DIR=/import/workflows/completed
mkdir -p "$ERROR_DIR"
mkdir -p "$COMPLETED_DIR"

# Validate n8n workflow based on official requirements
validate_workflow() {
    file="$1"
    workflow_name=$(basename "$file" .json)
    
    echo "→ Analyzing: $workflow_name"
    
    if node -e "
        const fs = require('fs');
        const file = '$file';
        const workflowName = '$workflow_name';
        
        try {
            let data;
            let rawContent;
            try {
                rawContent = fs.readFileSync(file, 'utf8');
                
                // Additional JSON validation - check for common issues
                if (!rawContent.trim()) {
                    console.error('ERROR: Empty file');
                    process.exit(1);
                }
                
                if (!rawContent.trim().startsWith('{') || !rawContent.trim().endsWith('}')) {
                    console.error('ERROR: Invalid JSON structure - must start with { and end with }');
                    process.exit(1);
                }
                
                // Check for incomplete JSON
                const openBraces = (rawContent.match(/\{/g) || []).length;
                const closeBraces = (rawContent.match(/\}/g) || []).length;
                if (openBraces !== closeBraces) {
                    console.error('ERROR: Unmatched braces in JSON');
                    process.exit(1);
                }
                
                // Try to parse
                data = JSON.parse(rawContent);
                
                // Validate it's actually an object
                if (!data || typeof data !== 'object' || Array.isArray(data)) {
                    console.error('ERROR: JSON must be an object');
                    process.exit(1);
                }
                
            } catch (error) {
                console.error('ERROR: Invalid JSON - ' + error.message);
                process.exit(1);
            }

            let hasErrors = false;
            let fixed = false;

            // Must have nodes array
            if (!data.nodes || !Array.isArray(data.nodes)) {
                console.error('ERROR: Missing nodes array');
                hasErrors = true;
            } else if (data.nodes.length === 0) {
                console.error('ERROR: Empty workflow');
                hasErrors = true;
            }

            // Check critical node properties and clean them
            if (data.nodes && Array.isArray(data.nodes)) {
                for (let i = 0; i < data.nodes.length; i++) {
                    const node = data.nodes[i];
                    
                    // Must have name and type
                    if (!node.name || typeof node.name !== 'string' || node.name.trim() === '') {
                        console.error('ERROR: Node ' + i + ' missing name');
                        hasErrors = true;
                    }
                    
                    if (!node.type || typeof node.type !== 'string') {
                        console.error('ERROR: Node ' + i + ' missing type');
                        hasErrors = true;
                    }

                    // Add missing required fields
                    if (!node.position || !Array.isArray(node.position)) {
                        node.position = [100 + (i * 200), 100];
                        fixed = true;
                    }
                    if (!node.hasOwnProperty('parameters')) {
                        node.parameters = {};
                        fixed = true;
                    }
                    if (!node.typeVersion) {
                        node.typeVersion = 1;
                        fixed = true;
                    }
                }
                
                            // Remove ALL IDs from ALL nodes to prevent conflicts - AGGRESSIVE CLEANING
            data.nodes.forEach(node => {
                const idFields = ['id', 'webhookId', 'uuid', 'instanceId', 'nodeId', '_id', 'identifier'];
                idFields.forEach(field => {
                    if (node[field]) {
                        delete node[field];
                        fixed = true;
                    }
                });
                
                // Clean parameters that might contain IDs
                if (node.parameters) {
                    // Remove webhook IDs from parameters
                    if (node.parameters.webhookId) {
                        delete node.parameters.webhookId;
                        fixed = true;
                    }
                    if (node.parameters.id) {
                        delete node.parameters.id;
                        fixed = true;
                    }
                }
                
                // Clean credentials that might have IDs
                if (node.credentials) {
                    Object.keys(node.credentials).forEach(credKey => {
                        if (node.credentials[credKey] && node.credentials[credKey].id) {
                            delete node.credentials[credKey].id;
                            fixed = true;
                        }
                    });
                }
            });
            }

            if (hasErrors) {
                process.exit(1);
            }

            if (!data.hasOwnProperty('connections')) {
                data.connections = {};
                fixed = true;
            }

            if (!data.name) {
                data.name = workflowName;
                fixed = true;
            }
            if (!data.hasOwnProperty('active')) {
                data.active = false;
                fixed = true;
            }

            // SUPER AGGRESSIVE CLEANING - Remove ALL problematic IDs and metadata
            const workflowIdFields = [
                'id', '_id', 'workflowId', 'uuid', 'versionId', 'instanceId',
                'createdAt', 'updatedAt', 'meta', 'staticData', 'tags',
                'hash', 'version', 'revision', 'executionId'
            ];
            
            workflowIdFields.forEach(field => {
                if (data[field]) {
                    delete data[field];
                    fixed = true;
                }
            });
            
            // Clean connections that might have IDs
            if (data.connections) {
                Object.keys(data.connections).forEach(nodeKey => {
                    if (data.connections[nodeKey]) {
                        Object.keys(data.connections[nodeKey]).forEach(outputKey => {
                            if (Array.isArray(data.connections[nodeKey][outputKey])) {
                                data.connections[nodeKey][outputKey].forEach(connection => {
                                    if (connection && connection.id) {
                                        delete connection.id;
                                        fixed = true;
                                    }
                                });
                            }
                        });
                    }
                });
            }
            
            // Force regenerate a completely clean name to avoid any hidden conflicts
            const cleanName = workflowName.replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 100);
            if (data.name !== cleanName) {
                data.name = cleanName;
                fixed = true;
            }
            
            // NUCLEAR OPTION - Remove ALL problematic content that causes transformer errors
            function deepCleanWorkflow(obj) {
                if (obj && typeof obj === 'object') {
                    if (Array.isArray(obj)) {
                        obj.forEach(item => deepCleanWorkflow(item));
                    } else {
                        Object.keys(obj).forEach(key => {
                            const value = obj[key];
                            
                            // Remove all ID-related fields
                            if (key.toLowerCase().includes('id') && key !== 'typeVersion' && key !== 'position') {
                                delete obj[key];
                                fixed = true;
                                return;
                            }
                            
                            // Remove problematic metadata fields that cause transformer errors
                            const problematicFields = [
                                'createdAt', 'updatedAt', 'versionId', 'hash', 'revision',
                                'executionId', 'instanceId', 'workflowId', 'meta', 'staticData',
                                'tags', 'settings', 'pinData', 'lastModified', 'owner',
                                'shared', 'history', 'version', 'uuid', '_id'
                            ];
                            
                            if (problematicFields.includes(key)) {
                                delete obj[key];
                                fixed = true;
                                return;
                            }
                            
                            // Clean parameter values that cause issues
                            if (key === 'parameters' && value && typeof value === 'object') {
                                Object.keys(value).forEach(paramKey => {
                                    const paramValue = value[paramKey];
                                    
                                    // Remove functions, undefined, symbols, circular refs
                                    if (typeof paramValue === 'function' || 
                                        typeof paramValue === 'undefined' || 
                                        typeof paramValue === 'symbol') {
                                        delete value[paramKey];
                                        fixed = true;
                                    }
                                    // Clean complex objects that might have circular refs
                                    else if (paramValue && typeof paramValue === 'object') {
                                        try {
                                            // Test if it can be safely serialized
                                            JSON.parse(JSON.stringify(paramValue));
                                        } catch (e) {
                                            // If not, replace with safe version or remove
                                            if (Array.isArray(paramValue)) {
                                                value[paramKey] = [];
                                            } else {
                                                value[paramKey] = {};
                                            }
                                            fixed = true;
                                        }
                                    }
                                });
                            }
                            
                            // Recursively clean nested objects
                            if (value && typeof value === 'object') {
                                deepCleanWorkflow(value);
                            }
                        });
                    }
                }
            }
            
            // Apply nuclear cleaning - remove ALL problematic content
            deepCleanWorkflow(data);
            
            // SPECIFIC FIX for transformer errors - Create completely new clean structure
            const cleanWorkflow = {
                name: data.name || workflowName,
                active: false,
                nodes: [],
                connections: data.connections || {}
            };
            
            // Copy only essential node data
            if (data.nodes && Array.isArray(data.nodes)) {
                data.nodes.forEach((node, index) => {
                    const cleanNode = {
                        name: node.name || 'Node_' + index,
                        type: node.type,
                        typeVersion: node.typeVersion || 1,
                        position: node.position || [100 + (index * 200), 100],
                        parameters: {}
                    };
                    
                    // Copy only safe parameters
                    if (node.parameters && typeof node.parameters === 'object') {
                        Object.keys(node.parameters).forEach(key => {
                            const value = node.parameters[key];
                            // Only copy primitive values and simple objects
                            if (typeof value === 'string' || 
                                typeof value === 'number' || 
                                typeof value === 'boolean' ||
                                value === null) {
                                cleanNode.parameters[key] = value;
                            } else if (Array.isArray(value)) {
                                // Copy simple arrays
                                cleanNode.parameters[key] = value.filter(item => 
                                    typeof item === 'string' || 
                                    typeof item === 'number' || 
                                    typeof item === 'boolean' ||
                                    item === null
                                );
                            } else if (value && typeof value === 'object') {
                                // Copy simple objects only
                                try {
                                    const testSerialization = JSON.stringify(value);
                                    const testParsing = JSON.parse(testSerialization);
                                    cleanNode.parameters[key] = testParsing;
                                } catch (e) {
                                    // Skip problematic objects
                                }
                            }
                        });
                    }
                    
                    cleanWorkflow.nodes.push(cleanNode);
                });
            }
            
            // Replace original data with clean version
            data = cleanWorkflow;
            fixed = true;

            // SUPER STRICT VALIDATION - Test every aspect that could cause runtime errors
            try {
                // Test basic serialization
                const testSerialization = JSON.stringify(data);
                const testParsing = JSON.parse(testSerialization);
                
                // Verify the structure is still intact after cleaning
                if (!testParsing.nodes || !Array.isArray(testParsing.nodes) || testParsing.nodes.length === 0) {
                    console.error('ERROR: Workflow structure corrupted during cleaning');
                    process.exit(1);
                }
                
                // DEEP VALIDATION - Check each node for problematic content
                for (let i = 0; i < data.nodes.length; i++) {
                    const node = data.nodes[i];
                    
                    // Test node serialization individually
                    try {
                        JSON.stringify(node);
                    } catch (nodeError) {
                        console.error('ERROR: Node ' + i + ' (' + (node.name || 'unnamed') + ') has corrupted data');
                        process.exit(1);
                    }
                    
                    // Clean problematic parameter values that cause runtime errors
                    if (node.parameters) {
                        // Remove circular references and problematic objects
                        try {
                            const paramStr = JSON.stringify(node.parameters);
                            node.parameters = JSON.parse(paramStr);
                        } catch (paramError) {
                            console.error('ERROR: Node ' + i + ' has corrupted parameters');
                            process.exit(1);
                        }
                        
                        // Clean specific problematic parameter types
                        Object.keys(node.parameters).forEach(paramKey => {
                            const paramValue = node.parameters[paramKey];
                            if (paramValue && typeof paramValue === 'object') {
                                // Remove functions, undefined, symbols that cause JSON issues
                                try {
                                    node.parameters[paramKey] = JSON.parse(JSON.stringify(paramValue));
                                } catch (e) {
                                    // If it can't be serialized, remove it
                                    delete node.parameters[paramKey];
                                    fixed = true;
                                }
                            }
                        });
                    }
                }
                
                // Test connections for corruption
                if (data.connections) {
                    try {
                        JSON.stringify(data.connections);
                    } catch (connError) {
                        console.error('ERROR: Connections data is corrupted');
                        process.exit(1);
                    }
                }
                
                // Final full workflow test
                const finalTest = JSON.stringify(data);
                JSON.parse(finalTest);
                
            } catch (error) {
                console.error('ERROR: Workflow fails deep validation - ' + error.message);
                process.exit(1);
            }

            // Save if fixed
            if (fixed) {
                try {
                    fs.writeFileSync(file, JSON.stringify(data, null, 2));
                } catch (error) {
                    console.error('ERROR: Cannot save cleaned file - ' + error.message);
                    process.exit(1);
                }
            }

            console.log('VALID');
            process.exit(0);

        } catch (error) {
            console.error('ERROR: ' + error.message);
            process.exit(1);
        }
    " 2>&1; then
        echo "  ✓ Valid"
        return 0
    else
        echo "  ✗ Invalid - moved to with_error"
        return 1
    fi
}

echo "=== Processing workflow files ==="
valid_count=0
error_count=0

# Store valid files for batch import
valid_files=""

# Process each JSON file in the workflows directory
for file in /import/workflows/*.json; do
    [ -e "$file" ] || continue
    
    workflow_name=$(basename "$file" .json)
    
    if validate_workflow "$file"; then
        valid_count=$((valid_count + 1))
        if [ -z "$valid_files" ]; then
            valid_files="$file"
        else
            valid_files="$valid_files $file"
        fi
        echo "  → $workflow_name marked for import"
    else
        mv "$file" "$ERROR_DIR/"
        error_count=$((error_count + 1))
    fi
done

echo ""
echo "=== Validation Summary ==="
echo "→ Valid workflows: $valid_count"
echo "→ Invalid workflows: $error_count (moved to with_error)"

echo ""
echo "=== Importing valid workflows ==="
if [ $valid_count -gt 0 ]; then
    echo "→ Importing $valid_count valid workflow(s)..."
    if n8n import:workflow --separate --input=/import/workflows 2>&1; then
        echo "  ✓ Workflows imported successfully"
        
        # Move successfully imported files to completed directory
        echo "→ Moving imported files to completed directory..."
        completed_count=0
        for file in $valid_files; do
            if [ -f "$file" ]; then
                workflow_name=$(basename "$file" .json)
                mv "$file" "$COMPLETED_DIR/"
                echo "  ✓ Moved $workflow_name to completed"
                completed_count=$((completed_count + 1))
            fi
        done
        
        echo "  ✓ $completed_count workflows moved to completed directory"
    else
        echo "  ⚠ Import failed - workflows remain in import directory for retry"
        echo "  ⚠ Check n8n logs for details"
    fi
else
    echo "→ No valid workflows to import"
fi

echo ""
echo "=== Importing credentials ==="
if ls /import/credentials/*.json >/dev/null 2>&1; then
    echo "→ Found credential files"
    n8n import:credentials --separate --input=/import/credentials
    echo "  ✓ Credentials imported"
else
    echo "→ No credential files found"
fi

echo ""
echo "✅ Import process completed"
echo ""
echo "=== Final Summary ==="
echo "→ Valid workflows processed: $valid_count"
echo "→ Invalid workflows (moved to with_error): $error_count"
if [ $valid_count -gt 0 ]; then
    echo "→ Successfully imported workflows (moved to completed): $valid_count"
fi

if [ $error_count -gt 0 ]; then
    echo ""
    echo "⚠  Check files in with_error directory for issues:"
    echo "   $ERROR_DIR"
fi

if [ $valid_count -gt 0 ]; then
    echo ""
    echo "✅ Successfully imported workflows can be found in:"
    echo "   $COMPLETED_DIR"
fi
