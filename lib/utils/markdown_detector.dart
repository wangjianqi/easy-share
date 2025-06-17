// 基础的启发式方法，用于检测字符串是否可能包含 Markdown 语法。
// 这不是一个完整的解析器，但旨在捕捉常见的 Markdown 模式。
bool isLikelyMarkdown(String text) {
  if (text.isEmpty) return false;

  // 常见的 Markdown 指示符正则表达式列表
  final patterns = [
    RegExp(r'^#+\s+\w+'), // 标题 (例如, # 标题)
    RegExp(r'^\*\s+\w+', multiLine: true), // 无序列表项 (例如, * 项目)
    RegExp(r'^-{3,}\s*$', multiLine: true), // 水平分割线 (例如, ---)
    RegExp(r'^>\s+\w+', multiLine: true), // 引用块 (例如, > 引用)
    RegExp(r'`{1,3}[^`]+`{1,3}'), // 行内代码或代码块 (例如, `code` 或 ```code```)
    RegExp(r'\*\*[^\*\n]+\*\*|__[^_\n]+__'), // 粗体 (例如, **bold** 或 __bold__) - 避免跨行匹配
    RegExp(r'\*[^*\n]+\*|_([^_]+)_'), // 斜体 (例如, *italic* 或 _italic_) - 避免跨行匹配
    RegExp(r'!\[[^\]]*\]\([^\)]+\)'), // 图片 (例如, ![alt](url))
    RegExp(r'(?<!\!)\[[^\]]+\]\([^\)]+\)'), // 链接 (例如, [text](url)) - 确保前面没有感叹号
    RegExp(r'^\d+\.\s+\w+', multiLine: true), // 有序列表项 (例如, 1. 项目)
  ];

  int matchCount = 0;
  for (var pattern in patterns) {
    if (pattern.hasMatch(text)) {
      matchCount++;
      // 如果已经找到足够多的模式，可以提前退出以提高效率
      if (matchCount >= 2) return true;
    }
  }

  // 如果至少有两个不同的 Markdown 模式被发现，则很可能是 Markdown
  if (matchCount >= 2) return true;

  // 在较长文本中，单个强指示符也很有可能
  if (matchCount == 1 && text.length > 30) return true;

  // 如果文本包含换行符且至少匹配一个模式，则增加可能性
  if (text.contains('\n') && matchCount > 0) return true;

  // 检查 Markdown 特殊字符的密度
  final markdownChars = RegExp(r'[\*#`\[\]\(\)>!\-_=]'); // 添加了 =
  if (text.length > 20) {
    final charCount = markdownChars.allMatches(text).length;
    // 如果超过10%的字符是类 Markdown 字符，并且至少匹配了一个模式
    if (charCount / text.length > 0.1 && matchCount > 0) {
      return true;
    }
  }

  // 如果以上条件都不满足，则认为不是 Markdown
  return false;
}
