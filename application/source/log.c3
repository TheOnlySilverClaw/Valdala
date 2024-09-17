module log;

import std::io;

enum Level {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL
}

struct ConsoleLogger {
    Level level;
    File* output;
}

fn void ConsoleLogger.logMessage(ConsoleLogger* log, Level level, String message, any*[] arguments) @private {
    (void) io::fprintf(log.output, "[%s] ", level);
    io::fprintfn(log.output, message, arguments);
}

fn void ConsoleLogger.logError(ConsoleLogger* log, Level level, String message, anyfault* error, any*[] arguments) @private {
    (void) io::fprintf(log.output, "[%s] ", level);
    (void) io::fprintf(log.output, message, arguments);
    io::fprintfn(log.output, "  %s", error);
}

fn void ConsoleLogger.trace(ConsoleLogger* log, String message, any*... arguments) =>
    ConsoleLogger.logMessage(log, TRACE, message, arguments);

fn void ConsoleLogger.debug(ConsoleLogger* log, String message, any*... arguments) =>
    ConsoleLogger.logMessage(log, DEBUG, message, arguments);

fn void ConsoleLogger.info(ConsoleLogger* log, String message, any*... arguments) =>
    ConsoleLogger.logMessage(log, INFO, message, arguments);

fn void ConsoleLogger.warn(ConsoleLogger* log, String message, anyfault* error, any*... arguments) =>
    ConsoleLogger.logError(log, WARN, message, error, arguments);

fn void ConsoleLogger.error(ConsoleLogger* log, String message, anyfault* error, any*... arguments) =>
    ConsoleLogger.logError(log, ERROR, message, error, arguments);

fn void ConsoleLogger.fatal(ConsoleLogger* log, String message, anyfault* error, any*... arguments) =>
    ConsoleLogger.logError(log, FATAL, message, error, arguments);
