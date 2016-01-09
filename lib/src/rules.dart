library rewrites.src.rules;

class RewriteRules {
  final List<RegExp> _ignore = [];
  final List<RewriteRule> _rules = [];

  List<RegExp> get ignored => _ignore;

  List<RewriteRule> get rules => _rules;

  ignore(Pattern pattern) => _ignore.add(new RegExp(pattern));

  ignoreAll(List<Pattern> patterns) => patterns.forEach(ignore);

  rewrite(Pattern pattern, String to) {
    _rules.add(new RewriteRule(new RegExp(pattern), to));
  }
}

class RewriteRule {
  final RegExp pattern;
  final String to;

  RewriteRule(this.pattern, this.to);
}
