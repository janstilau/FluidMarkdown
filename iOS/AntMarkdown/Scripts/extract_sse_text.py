#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extract the "data:" text parts from an SSE log/text file and output pure text.
Usage:
    python3 extract_sse_text.py /path/to/your/file.txt

This script scans for lines starting with "data:". If the payload is a JSON
object, it extracts the "text" field. If it's a quoted JSON string, it decodes
it. Otherwise it treats the payload as plain text. Contiguous "data:" lines are
combined as one payload (joined with newlines).
"""

import argparse
import json
import sys
from typing import List


def extract_texts_from_sse(path: str) -> str:
    outputs: List[str] = []
    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Failed to read file: {e}", file=sys.stderr)
        return ""

    i = 0
    n = len(lines)
    while i < n:
        stripped = lines[i].strip()
        if stripped.startswith('data:'):
            payload_lines: List[str] = []
            # Accumulate contiguous data lines
            while i < n and lines[i].strip().startswith('data:'):
                payload = lines[i].strip()[len('data:'):].strip()
                payload_lines.append(payload)
                i += 1
            combined = "\n".join(payload_lines).strip()

            text_val = None
            # Try JSON object (e.g., {"text":"...","type":"answering"})
            try:
                if combined.startswith('{') and combined.endswith('}'):
                    obj = json.loads(combined)
                    if isinstance(obj, dict):
                        if 'text' in obj:
                            text_val = obj['text']
                        elif 'data' in obj and isinstance(obj['data'], str):
                            # Fallback: if payload is a JSON with a 'data' string
                            text_val = obj['data']
                        else:
                            # As a last resort, stringify
                            text_val = combined
                    else:
                        text_val = combined
                # Try quoted JSON string (e.g., "..." or '...')
                elif (combined.startswith('"') and combined.endswith('"')) or (
                    combined.startswith("'") and combined.endswith("'")):
                    text_val = json.loads(combined)
                else:
                    # Plain text payload
                    text_val = combined
            except Exception:
                # On JSON parse failure, treat as plain text
                text_val = combined

            if text_val is not None:
                outputs.append(text_val)
            # Continue without incrementing i here (already advanced in the inner loop)
            continue
        else:
            i += 1

    return "\n".join(outputs)


def main():
    parser = argparse.ArgumentParser(description='Extract text fields from SSE data lines in a file.')
    parser.add_argument('path', help='Path to the input text file')
    args = parser.parse_args()

    result = extract_texts_from_sse(args.path)
    # Print pure text to stdout
    print(result)


if __name__ == '__main__':
    main()