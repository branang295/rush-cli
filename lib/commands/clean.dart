import 'package:get_it/get_it.dart';
import 'package:interact/interact.dart';
import 'package:path/path.dart' as p;
import 'package:rush_cli/commands/rush_command.dart';
import 'package:rush_cli/services/file_service.dart';
import 'package:rush_cli/utils/file_extension.dart';
import 'package:tint/tint.dart';

import '../services/logger.dart';

class CleanCommand extends RushCommand {
  final _fs = GetIt.I<FileService>();
  final _lgr = GetIt.I<Logger>();

  @override
  String get description => 'Deletes old build files and caches.';

  @override
  String get name => 'clean';

  @override
  Future<int> run() async {
    if (!await _isRushProject()) {
      _lgr.err('Not a Rush project.');
      return 1;
    }

    final spinner = Spinner(
        icon: '\n✅ '.green(),
        rightPrompt: (done) => done
            ? '${'Success!'.green()} Deleted build files and caches'
            : 'Cleaning...').interact();
    for (final file in _fs.dotRushDir.listSync()) {
      file.deleteSync(recursive: true);
    }

    spinner.done();
    return 0;
  }

  Future<bool> _isRushProject() async {
    final config = _fs.configFile;
    final androidManifest =
        p.join(_fs.srcDir.path, 'AndroidManifest.xml').asFile();
    return await config.exists() &&
        await _fs.srcDir.exists() &&
        await androidManifest.exists() &&
        await _fs.dotRushDir.exists();
  }
}
