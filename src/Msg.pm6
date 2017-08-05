
unit package Msg;

use JSON::Fast;

my $io-log = open "io.log", :a;

sub client-send($bot, $msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  my $len = $msg-json.chars + 1;
  $io-log.say("client-send: $msg-json");
  $io-log.flush;
  $bot.in.say("$len:$msg-json");
}

sub client-get($bot) is export {
  # my $msg = $bot.out.get;
  # my $msg = $bot.out.get;
  # $msg ~~ / ^^ (\d+) \: (.*) /;
  # my $len = $0;
  # my $msg-json = $1;
  my $msg-json = read-thing($bot.out);
  $io-log.say("client-get: $msg-json");
  $io-log.flush;
  from-json($msg-json);
}

sub server-send($msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  # $msg-json ~= "\n";
  my $len = $msg-json.chars + 1;
  $io-log.say("server-send: $msg-json");
  $io-log.flush;
  $*OUT.say("$len:$msg-json");
  $*OUT.flush;
}

sub read-thing($fh) {
  my $buffer = $fh.readchars(1);
  $io-log.say("server-get buffer: [$buffer]");
  $io-log.flush;
  while $buffer.substr(*-1) ne ':' {
    $buffer ~= $fh.readchars(1);
    $io-log.say("server-get buffer: [$buffer]");
    $io-log.flush;
    $buffer ~~ s:g/ \n / /;
  }
  my $len = $buffer.substr(0, *-1);
  $io-log.say("server-get reading: {$len}");
  $fh.read($len.Int).decode;
}

sub server-get is export {
      # sleep 0.01;
  $io-log.say("server-get: waiting");
  $io-log.flush;
  # my $msg = $*IN.get;

  my $msg-json = read-thing($*IN);

  $io-log.say("server-get got msg: $msg-json");
  $io-log.flush;
  # $msg ~~ / ^^ (\d+) \: (.*) $ /;
  # my $len = $0;
  # my $msg-json = $1;
  # $io-log.say("server-get match: { $/.gist }");
  # $io-log.say("server-get msg-json: $msg-json");
  my $result = from-json($msg-json);
  return $result;
  CATCH {
    default {
      $io-log.print(".");
      $io-log.flush;
      # sleep 0.01;
      $io-log.say(.^name, do given .backtrace[0] { .file, .line, .subname });
      # $io-log.flush;
      return server-get();
    }
  }
}

sub bot-send($bot, $msg) is export {
  my $msg-json = to-json($msg) :!pretty;
  $io-log.say("bot-send: $msg-json");
  $io-log.flush;
  $bot.in.say($msg-json);
}

sub bot-get($bot) is export {
  my $msg = $bot.out.get;
  $io-log.say("bot-get: $msg");
  $io-log.flush;
  from-json($msg);
}

