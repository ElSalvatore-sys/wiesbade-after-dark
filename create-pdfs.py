#!/usr/bin/env python3
"""
Convert markdown launch guides to printable PDFs
"""

import markdown
import os
from pathlib import Path

def markdown_to_html(md_file):
    """Convert markdown to HTML"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert markdown to HTML with extensions
    html = markdown.markdown(
        md_content,
        extensions=['tables', 'fenced_code', 'toc']
    )
    
    # Add CSS styling for print
    styled_html = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{Path(md_file).stem}</title>
    <style>
        @page {{
            size: A4;
            margin: 2.5cm;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #333;
            max-width: 21cm;
            margin: 0 auto;
            padding: 20px;
        }}
        
        h1 {{
            color: #1a1a1a;
            border-bottom: 3px solid #7C3AED;
            padding-bottom: 10px;
            margin-top: 30px;
            page-break-before: auto;
        }}
        
        h2 {{
            color: #333;
            border-bottom: 2px solid #EC4899;
            padding-bottom: 8px;
            margin-top: 25px;
            page-break-after: avoid;
        }}
        
        h3 {{
            color: #444;
            margin-top: 20px;
            page-break-after: avoid;
        }}
        
        table {{
            border-collapse: collapse;
            width: 100%;
            margin: 15px 0;
            page-break-inside: avoid;
        }}
        
        th, td {{
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }}
        
        th {{
            background-color: #7C3AED;
            color: white;
            font-weight: bold;
        }}
        
        tr:nth-child(even) {{
            background-color: #f9f9f9;
        }}
        
        code {{
            background-color: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 10pt;
        }}
        
        pre {{
            background-color: #f4f4f4;
            padding: 12px;
            border-radius: 5px;
            overflow-x: auto;
            page-break-inside: avoid;
        }}
        
        pre code {{
            background: none;
            padding: 0;
        }}
        
        ul, ol {{
            margin: 10px 0;
            padding-left: 30px;
        }}
        
        li {{
            margin: 5px 0;
        }}
        
        blockquote {{
            border-left: 4px solid #7C3AED;
            padding-left: 15px;
            margin: 15px 0;
            color: #666;
            font-style: italic;
        }}
        
        hr {{
            border: none;
            border-top: 2px solid #eee;
            margin: 25px 0;
        }}
        
        a {{
            color: #7C3AED;
            text-decoration: none;
        }}
        
        a:hover {{
            text-decoration: underline;
        }}
        
        .checkbox {{
            margin-right: 8px;
        }}
        
        @media print {{
            body {{
                padding: 0;
            }}
            
            h1, h2, h3 {{
                page-break-after: avoid;
            }}
            
            table, figure, pre {{
                page-break-inside: avoid;
            }}
            
            a[href]:after {{
                content: none !important;
            }}
        }}
    </style>
</head>
<body>
    {html}
</body>
</html>
"""
    
    return styled_html

def main():
    print("=== CONVERTING LAUNCH GUIDES TO PRINTABLE HTML ===")
    print("")
    
    # Create output directory
    os.makedirs('launch-pdfs', exist_ok=True)
    
    files = [
        'LAUNCH_DAY_CHECKLIST.md',
        'STAFF_QUICK_START_GUIDE.md',
        'MANAGER_LAUNCH_GUIDE.md'
    ]
    
    for md_file in files:
        if not os.path.exists(md_file):
            print(f"❌ {md_file} not found")
            continue
        
        print(f"📄 Converting {md_file}...")
        
        try:
            html = markdown_to_html(md_file)
            html_file = f"launch-pdfs/{Path(md_file).stem}.html"
            
            with open(html_file, 'w', encoding='utf-8') as f:
                f.write(html)
            
            print(f"✅ Created {html_file}")
            print(f"   → Open in browser and Print to PDF (Cmd+P)")
            
        except Exception as e:
            print(f"❌ Error converting {md_file}: {e}")
    
    print("")
    print("=== CONVERSION COMPLETE ===")
    print("")
    print("To create PDFs:")
    print("1. Open each HTML file in your browser")
    print("2. Press Cmd+P (or Ctrl+P)")
    print("3. Select 'Save as PDF'")
    print("4. Save to launch-pdfs/ directory")
    print("")
    print("HTML files are in: launch-pdfs/")

if __name__ == '__main__':
    main()

