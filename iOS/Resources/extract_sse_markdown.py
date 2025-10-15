#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SSE数据Markdown提取器
从SSE（Server-Sent Events）数据文件中提取type为"answering"的text内容，
并将其转换为标准的Markdown文件。

使用方法:
python extract_sse_markdown.py <sse_file_path> [output_file_path]

参数:
- sse_file_path: SSE数据文件路径
- output_file_path: 输出的Markdown文件路径（可选，默认为input_file.md）
"""

import json
import sys
import os
import re
from typing import List, Optional


def parse_sse_line(line: str) -> Optional[dict]:
    """
    解析SSE数据行
    
    Args:
        line: SSE数据行
        
    Returns:
        解析后的数据字典，如果不是data行则返回None
    """
    line = line.strip()
    if not line.startswith('data:'):
        return None
    
    # 提取data后面的JSON字符串
    json_str = line[5:]  # 去掉"data:"前缀
    
    try:
        return json.loads(json_str)
    except json.JSONDecodeError:
        return None


def unescape_text(text: str) -> str:
    """
    处理转义字符，将\\n、\\t等转换为真实的换行符和制表符
    
    Args:
        text: 包含转义字符的文本
        
    Returns:
        处理后的文本
    """
    # 处理常见的转义字符
    text = text.replace('\\n', '\n')
    text = text.replace('\\t', '\t')
    text = text.replace('\\r', '\r')
    text = text.replace('\\"', '"')
    text = text.replace("\\'", "'")
    text = text.replace('\\\\', '\\')
    
    return text


def extract_markdown_from_sse(sse_file_path: str) -> str:
    """
    从SSE文件中提取Markdown内容
    
    Args:
        sse_file_path: SSE数据文件路径
        
    Returns:
        提取的Markdown内容
    """
    markdown_parts = []
    
    try:
        with open(sse_file_path, 'r', encoding='utf-8') as file:
            for line_num, line in enumerate(file, 1):
                data = parse_sse_line(line)
                
                if data is None:
                    continue
                
                # 检查是否为answering类型的消息
                if data.get('type') == 'answering' and 'text' in data:
                    text = data['text']
                    # 处理转义字符
                    unescaped_text = unescape_text(text)
                    markdown_parts.append(unescaped_text)
                    
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{sse_file_path}'")
        sys.exit(1)
    except Exception as e:
        print(f"错误: 读取文件时发生异常: {e}")
        sys.exit(1)
    
    # 合并所有文本片段
    return ''.join(markdown_parts)


def save_markdown(content: str, output_path: str) -> None:
    """
    保存Markdown内容到文件
    
    Args:
        content: Markdown内容
        output_path: 输出文件路径
    """
    try:
        # 确保输出目录存在
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        with open(output_path, 'w', encoding='utf-8') as file:
            file.write(content)
        
        print(f"Markdown文件已保存到: {output_path}")
        print(f"文件大小: {len(content)} 字符")
        
    except Exception as e:
        print(f"错误: 保存文件时发生异常: {e}")
        sys.exit(1)


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("使用方法: python extract_sse_markdown.py <sse_file_path> [output_file_path]")
        print("示例: python extract_sse_markdown.py dataxiaop2.txt output.md")
        sys.exit(1)
    
    sse_file_path = sys.argv[1]
    
    # 确定输出文件路径
    if len(sys.argv) >= 3:
        output_file_path = sys.argv[2]
    else:
        # 默认输出文件名：输入文件名.md
        base_name = os.path.splitext(os.path.basename(sse_file_path))[0]
        output_file_path = f"{base_name}.md"
    
    print(f"正在处理SSE文件: {sse_file_path}")
    
    # 提取Markdown内容
    markdown_content = extract_markdown_from_sse(sse_file_path)
    
    if not markdown_content.strip():
        print("警告: 没有找到任何answering类型的文本内容")
        return
    
    # 保存到文件
    save_markdown(markdown_content, output_file_path)


if __name__ == "__main__":
    main()