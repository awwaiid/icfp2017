
unit package Msg;

use JSON::Fast;

sub client-send($bot, $msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  my $len = $msg-json.chars;
  $bot.in.say("$len:$msg-json");
}

sub client-get($bot) is export {
  my $msg = $bot.out.get;
  $msg ~~ / ^^ (\d+) \: (.*) /;
  my $len = $0;
  my $msg-json = $1;
  # $*ERR.say("client-get: $msg");
  from-json($msg-json);
}

sub server-send($msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  my $len = $msg-json.chars;
  say("$len:$msg-json");
}

sub server-get is export {
  my $msg = $*IN.get;
  # $*ERR.say("server-get: $msg");
  $msg ~~ / ^^ (\d+) \: (.*) $ /;
  my $len = $0;
  my $msg-json = $1;
  # $*ERR.say("server-get match: { $/.gist }");
  # $*ERR.say("server-get msg-json: $msg-json");
  from-json($msg-json);
}

sub bot-send($bot, $msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  $bot.in.say($msg-json);
}

sub bot-get($bot) is export {
  my $msg = $bot.out.get;
  from-json($msg);
}

