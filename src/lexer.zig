const std = @import("std");

pub const TokenType = enum {
    left_paren,
    right_paren,
    left_bracket,
    right_bracket,
    equal,
    slash,
    comment,
    discard,
    literal,
    string,
    eof,
};

pub const Token = struct {
    type: TokenType,
    value: []const u8,
    start_line: usize,
    start_column: usize,
    end_line: usize,
    end_column: usize,
};

pub const Lexer = struct {
    source: []const u8,
    line: usize,
    column: usize,
    start_index: usize,
    current_index: usize,

    pub fn init(source: []const u8) Lexer {
        return .{
            .source = source,
            .line = 0,
            .column = 0,
            .start_index = 0,
            .current_index = 0,
        };
    }

    pub fn isAtEnd(self: Lexer) bool {
        return self.current_index >= self.source.len;
    }

    fn advance(self: *Lexer) void {
        if (!self.isAtEnd()) {
            if (self.peek() == '\n') {
                self.line += 1;
                self.column = 0;
            } else {
                self.column += 1;
            }
            self.current_index += 1;
        }
    }

    fn peek(self: Lexer) u8 {
        return self.source[self.current_index];
    }

    fn peekNext(self: Lexer) ?u8 {
        return if (self.current_index + 1 < self.source.len) self.source[self.current_index + 1] else null;
    }

    fn discard(self: *Lexer) void {
        self.start_index = self.current_index;
    }

    fn token(self: Lexer, token_type: TokenType) Token {
        return .{
            .type = token_type,
            .value = self.source[self.start_index..self.current_index],
            .start_line = self.line,
            .start_column = self.column + self.start_index - self.current_index,
            .end_line = self.line,
            .end_column = self.column,
        };
    }

    fn multilineToken(self: Lexer, token_type: TokenType, s_line: usize, s_col: usize) Token {
        return .{
            .type = token_type,
            .value = self.source[self.start_index..self.current_index],
            .start_line = s_line,
            .start_column = s_col,
            .end_line = self.line,
            .end_column = self.column,
        };
    }

    fn isLiteral(c: u8) bool {
        return switch (c) {
            ' ', '\t', '\r', '\n', '(', ')', '[', ']', '=', ';' => false,
            else => true,
        };
    }

    fn comment(self: *Lexer) Token {
        // discard ;
        self.discard();
        while (!self.isAtEnd() and self.peek() != '\n') self.advance();
        return self.token(.comment);
    }

    fn literal(self: *Lexer) Token {
        while (!self.isAtEnd() and isLiteral(self.peek())) self.advance();
        const val = self.source[self.start_index..self.current_index];
        return self.token(if (val.len == 1 and val[0] == '_') .discard else .literal);
    }

    fn string(self: *Lexer) !Token {
        // discard opening quote
        self.discard();

        const start_line = self.line;
        const start_col = self.column;

        while (!self.isAtEnd()) {
            if (self.peek() == '"') {
                if (self.peekNext() == '"') {
                    self.advance();
                } else {
                    break;
                }
            }
            self.advance();
        }

        if (self.isAtEnd()) {
            std.debug.print("[{d}, {d}]-[{d}, {d}] Unterminated string\n", .{
                start_line + 1,
                start_col,
                self.line + 1,
                self.column,
            });
            return error.Syntax;
        }

        const tok = self.multilineToken(.string, start_line, start_col);

        // discard closing quote
        self.advance();
        self.discard();

        return tok;
    }

    pub fn lexToken(self: *Lexer) !Token {
        self.discard();

        while (!self.isAtEnd()) {
            const c = self.peek();
            self.advance();

            switch (c) {
                ' ', '\t', '\r', '\n' => self.discard(),
                '(' => return self.token(.left_paren),
                ')' => return self.token(.right_paren),
                '[' => return self.token(.left_bracket),
                ']' => return self.token(.right_bracket),
                '=' => return self.token(.equal),
                '/' => return self.token(.slash),
                ';' => return self.comment(),
                '"' => return self.string(),
                else => return self.literal(),
            }
        }

        return self.token(.eof);
    }
};
