# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

USLM (United States Legislative Markup) is an XML-based information model for representing U.S. Congressional legislation. It's the official schema maintained by the Government Publishing Office (GPO) for encoding bills, resolutions, statutes, and titles of the United States Code.

## Commands

### XML to HTML Transformation
```bash
# Transform a single USLM XML file to HTML
xsltproc uslm-to-html.xsl input.xml > output.html

# Batch convert multiple files
./convert-all.sh [xml_dir] [html_dir]
```

### Schema Validation
```bash
# Validate XML against USLM schema
xmllint --schema uslm-2.1.0.xsd --noout file.xml
```

## Architecture

### Schema Organization
- **Main Schema**: `uslm-[version].xsd` - Core USLM schema defining document structure
- **Components**: `uslm-components-[version].xsd` - Reusable element definitions
- **Table Module**: `uslm-table-module-[version].xsd` - XHTML table support
- **Math Module**: `uslm-mathml-module-[version].xsd` - MathML integration

### Transformation Pipeline
The XSLT stylesheet `uslm-to-html.xsl` implements 10 transformation rules mapping USLM XML to HTML5:
- Inline elements → `<span>` with class composition
- Block elements → `<div>` with class composition
- Layout elements → `<table>` structures
- Attributes prefixed with `data-uslm-` for non-standard mappings
- CSS classes follow pattern: `elementName_roleValue className`

### Key Design Patterns
- **Namespace Management**: Consistent use of `xmlns:uslm="http://docs.oasis-open.org/legaldocml/ns/us/2.1.0"`
- **ID Convention**: Globally unique GUIDs with "id" prefix (e.g., `id="id123e4567"`)
- **Naming Convention**: lowerCamelCase for elements/attributes, UpperCamelCase for types/groups
- **Extensibility**: Schema inheritance allows custom extensions via `xs:extension`

## Sample Files

Test transformations using files in:
- `/bill-version-samples-september-2024/` - Current bill format examples
- `/previous/sample-files/` - Legacy format examples

## CSS Styling

Two main stylesheets control presentation:
- `uslm.css` - Core USLM styling rules
- `uslm-html.css` - HTML-specific presentation

Key CSS features:
- Hanging indents for legislative text
- Multi-level list formatting
- Table of contents generation
- Print-optimized layouts
- Research References & Practice Aids
## Cross references. 
* Powers and duties of Code Revision Commission regarding publication of Code, §§ 28-9-3, 28-9-5.

* Effect of reenactment of the Code, § 28-9-5.

* Authorization to use state emblem on cover of official Code, § 50-3-8(b).

## Law reviews. 
* For discussion of the work of the Code Revision Commission in making the Code, see 18 Ga. St. B.J. 102 (1982).

* For article, “Researching Georgia Law,” see 9 Ga. St. U. L. Rev. 585 (1993).

* For article, “Researching Georgia Law,” see 34 Ga. St. U. L. Rev. 741 (2015).

* For article, “Code Revision Commission v. Public.Resource.Org and the Fight Over Copyright Protection for Annotations and Commentary,” see 54 Ga. L. Rev. 111 (2019).

## Hierarchy Notes: 
O.C.G.A. Title 1, Ch. 1