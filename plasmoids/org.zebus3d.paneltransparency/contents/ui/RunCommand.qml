import QtQuick
import org.kde.plasma.plasma5support as P5Support

// Minimal fire-and-forget command runner (plasma5support executable engine).
P5Support.DataSource {
    id: dataSource

    engine: "executable"
    connectedSources: []

    signal commandFinished(string command, int exitCode, string stdout)

    function exec(cmd) {
        dataSource.connectSource(cmd);
    }

    onNewData: (source, data) => {
        const exitCode = data["exit code"];
        const stdout = data["stdout"];
        dataSource.disconnectSource(source);
        commandFinished(source, exitCode, stdout);
    }
}
