# USLM to HTML Transformation

This directory contains an XSLT stylesheet (`uslm-to-html.xsl`) that transforms USLM-compliant XML files to HTML according to the specifications in the USLM User Guide Section 8.3.

## Files

- **`uslm-to-html.xsl`** - The main XSLT stylesheet
- **`uslm.css`** - Required CSS stylesheet for proper rendering
- **`test-output.html`** - Example output from the transformation

## Usage

### Command Line (using xsltproc)

```bash
# Transform a USLM XML file to HTML
xsltproc --output output.html uslm-to-html.xsl input.xml

# Example with sample file
xsltproc --output route66-bill.html uslm-to-html.xsl bill-version-samples-september-2024/BILLS-116s1014es.xml
```

### Python (using lxml)

```python
from lxml import etree

# Load the XML and XSLT files
xml_doc = etree.parse('bill-version-samples-september-2024/BILLS-116s1014es.xml')
xslt_doc = etree.parse('uslm-to-html.xsl')

# Transform the XML using the XSLT
transform = etree.XSLT(xslt_doc)
result = transform(xml_doc)

# Save the resulting HTML
with open('output.html', 'wb') as f:
    f.write(etree.tostring(result, pretty_print=True, method="html"))
```

### Node.js (using saxon-js)

```javascript
const SaxonJS = require('saxon-js');

// Transform XML to HTML
const result = SaxonJS.transform({
    stylesheetFileName: 'uslm-to-html.xsl',
    sourceFileName: 'input.xml',
    destination: 'file'
});
```

## Transformation Rules Implemented

The XSLT implements all 10 transformation rules from USLM User Guide Section 8.3:

1. **Marker/Inline/String types** → `<span>` elements
2. **Block/Content types** → `<div>` elements
3. **Layout elements** → `<table>` elements with proper `<tr>`/`<td>` structure
4. **@role attribute** → HTML5 `@role` attribute (or element name if no role)
5. **@class attribute** → Composed as `elementName_roleValue className1 className2`
6. **@xml:lang** → HTML5 `@lang` attribute
7. **Direct attributes** → `@style`, `@id`, `@href`, `@idref`, `@src`, `@alt`, `@colspan`, `@rowspan`
8. **Other attributes** → Prefixed with `data-uslm-`
9. **Document structure** → Wrapped in HTML5 `<body>` element
10. **CSS integration** → Automatic `uslm.css` reference

## Features

- **Complete HTML5 document** - Includes proper `<html>`, `<head>`, and `<body>` structure
- **CSS integration** - Automatically includes reference to `uslm.css`
- **Metadata handling** - Dublin Core elements are preserved but hidden
- **Namespace support** - Handles USLM, Dublin Core, and XHTML namespaces
- **Attribute preservation** - All XML attributes are preserved according to USLM rules
- **XSLT 1.0 compatible** - Works with standard XSLT processors

## Output Structure

The generated HTML follows this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>[Document Title from DC metadata]</title>
    <link rel="stylesheet" type="text/css" href="uslm.css">
</head>
<body>
    <div role="bill" class="bill" id="..." data-uslm-*="...">
        <!-- Transformed USLM content -->
    </div>
</body>
</html>
```

## CSS Classes

The transformation generates CSS classes following the USLM pattern:
- `elementName` - Base element name
- `elementName_roleValue` - When element has a role attribute
- `elementName_roleValue additionalClasses` - When element has both role and class attributes

Examples:
- `<section>` → `class="section"`
- `<level role="Chapter">` → `class="level_Chapter"`
- `<content class="block">` → `class="content block"`
- `<shortTitle role="act">` → `class="shortTitle_act"`

## Requirements

- XSLT 1.0 processor (xsltproc, Saxon, etc.)
- The `uslm.css` file must be available in the same directory as the output HTML
- Input XML must be valid USLM format

## Testing

The transformation has been tested with:
- Sample bills from `bill-version-samples-september-2024/`
- Various USLM element types and attribute combinations
- CSS rendering verification

## Compatibility

- XSLT 1.0 (compatible with most processors)
- HTML5 output
- Modern browsers with CSS support
