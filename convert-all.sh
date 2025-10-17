#!/bin/bash

# USLM XML to HTML Batch Converter
# Usage: ./convert-all.sh [xml_dir] [html_dir]

XML_DIR=${1:-xml}
HTML_DIR=${2:-html}

# Create output directory if it doesn't exist
mkdir -p "$HTML_DIR"

# Check if XML directory exists
if [ ! -d "$XML_DIR" ]; then
    echo "Error: XML directory '$XML_DIR' not found"
    exit 1
fi

# Check if XSLT file exists
if [ ! -f "uslm-to-html.xsl" ]; then
    echo "Error: uslm-to-html.xsl not found in current directory"
    exit 1
fi

# Count XML files
xml_count=$(find "$XML_DIR" -name "*.xml" | wc -l)
if [ "$xml_count" -eq 0 ]; then
    echo "No XML files found in '$XML_DIR'"
    exit 1
fi

echo "Converting $xml_count XML files from '$XML_DIR' to '$HTML_DIR'..."

# Convert all XML files
converted=0
failed=0

for xml_file in "$XML_DIR"/*.xml; do
    if [ -f "$xml_file" ]; then
        base_name=$(basename "$xml_file" .xml)
        html_file="$HTML_DIR/${base_name}.html"
        
        echo "Converting: $xml_file -> $html_file"
        
        if xsltproc --output "$html_file" uslm-to-html.xsl "$xml_file" 2>/dev/null; then
            ((converted++))
        else
            echo "  ERROR: Failed to convert $xml_file"
            ((failed++))
        fi
    fi
done

echo ""
echo "Conversion complete!"
echo "  Successfully converted: $converted files"
echo "  Failed: $failed files"
echo "  Output directory: $HTML_DIR"

# Copy CSS file to HTML directory for proper styling
if [ -f "uslm-html.css" ]; then
    cp "uslm-html.css" "$HTML_DIR/"
    echo "  CSS file copied to output directory"
fi

