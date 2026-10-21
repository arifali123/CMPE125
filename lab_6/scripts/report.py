#!/usr/bin/env python3
"""Build the printable report: uv run --with markdown --with weasyprint .../report.py."""
from pathlib import Path
import markdown
from weasyprint import HTML

lab_dir = Path(__file__).resolve().parents[1]
notes = lab_dir / 'notes'
source = (notes / 'report.md').read_text()
for title, relative in [
    ('Appendix A: synthesizable Verilog', 'rtl/vending_machine.v'),
    ('Appendix B: simulation testbench', 'sim/vending_machine_tb.v'),
    ('Appendix C: input and expected-output vectors', 'sim/test_vector.tv'),
]:
    source += f'\n\n## {title}\n\n```text\n{(lab_dir / relative).read_text()}```\n'
body = markdown.markdown(source, extensions=['tables', 'fenced_code'])
style = '''
@page { size: Letter; margin: 0.65in;
  @bottom-right { content: counter(page); font: 9pt sans-serif; color: #64748b; }
}
body { font-family: DejaVu Sans, sans-serif; font-size: 9.5pt; line-height: 1.48; color: #16243a; }
h1 { font-size: 24pt; line-height: 1.2; color: #173e75; }
h2 { font-size: 15pt; color: #173e75; margin-top: 22pt; break-after: avoid; }
h3 { font-size: 11pt; margin-top: 15pt; break-after: avoid; }
p { orphans: 3; widows: 3; }
a { color: #174ea6; text-decoration: none; }
img { width: 100%; height: auto; }
p:has(img) { break-inside: avoid; }
table { width: 100%; border-collapse: collapse; margin: 12pt 0; font-size: 8.4pt; }
th { background: #e7eef8; text-align: left; }
td, th { padding: 5pt; border: 0.5pt solid #c5cfdd; }
tr { break-inside: avoid; }
pre { font-family: DejaVu Sans Mono, monospace; font-size: 7.1pt; line-height: 1.45;
      white-space: pre-wrap; overflow-wrap: anywhere; background: #f3f6fa; padding: 9pt; }
code { font-family: DejaVu Sans Mono, monospace; font-size: 0.9em; }
h2[id^="appendix"] { break-before: page; }
'''
# Assign stable heading IDs for print page breaks on code appendices.
for letter in 'abc':
    body = body.replace(f'<h2>Appendix {letter.upper()}:', f'<h2 id="appendix-{letter}">Appendix {letter.upper()}:')
html = f'<!doctype html><html><meta charset="utf-8"><title>CMPE 125 Lab 6</title><style>{style}</style><body>{body}</body></html>'
(lab_dir / 'build').mkdir(exist_ok=True)
(lab_dir / 'build' / 'report.html').write_text(html)
HTML(string=html, base_url=str(notes)).write_pdf(notes / 'report.pdf')
print(notes / 'report.pdf')
