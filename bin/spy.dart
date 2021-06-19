import 'dart:convert' as convert;

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption(
    'github-token',
    abbr: 'token',
    help:
        'Provide a GitHub token to make GitHub issues to the PrivacySpy repository.',
    valueHelp: 'github-token',
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'See how to use the PrivacySpy bot',
  );

  var args = parser.parse(arguments);
  if (args['help'] == true) {
    return printUsage(parser);
  }

  var token = args['token'];
  var gh = GitHub(auth: Authentication.withToken(token));
  var db = Uri.https('www.privacyspy.org', '/api/v2/index.json');

  var resp = await http.get(db);
  if (resp.statusCode == 200) {
    var jsonRes = convert.jsonDecode(resp.body);
    jsonRes.slug.forEach(() => search(jsonRes.slug));
  }
}

search(String slug) async {
  var req = Uri.https('www.privacyspy.org', '/api/v2/product/$slug.json');
  var res = await http.get(req);
  if (res.statusCode == 200) {
    var body = convert.jsonDecode(res.body);
    var policies = body.sources.forEach((v) => v.append());
    var i = 0;
    for (i; policies.length; i++) {
      var resp = await http.get(policies[i]);
      if (resp.statusCode == 200) {
        var body = resp.body;
        throw UnimplementedError();
      }
    }
  }
}

createIssue(IssueRequest gh, String product, String quote, String url) {
  IssueRequest(
    title: 'Citation for $product not found',
    body:
        'The product, [$product,]($url) has a missing quote.\n\n```$quote```---I\'m just a bot, so I\'m not perfect. Let us know if I\'ve made a mistake. :relaxed:',
    labels: ['product', 'help wanted', 'problem'],
  );
}

void printUsage(ArgParser parser) {
  print('');
  print('PrivacySpy Bot – Time to track some online privacy.');
  print('Licensed under the GNU General Public license (v3.0).');
  print('Source: https://github.com/doamatto/privacyspy-bot');
  print('');
  print('=== === ===');
  print('');
  print(parser.usage);
}