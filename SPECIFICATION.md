# TYON 0.6.0

Typed Object Notation

## Specifications

* TYON is case-sensitive.
* A TYON file must be a valid UTF-8 encoded document.
* Whitespace is `space` (0x20), `tab` (0x09), `CR` (0x0D), and `LF` (0x0A).
* The recommended file extension is `.tyon`

## File

A file is an implicit [map](#map) of [key / value pairs](#key--value-pair) that can also contain [type definitions](#type-definition).

```lisp
; key / value pairs
first = 1
second = maybe

; defining the type 'person'
/person = (first-name middle-initial last-name age)
```

## Comment

A comment begins with `;` and continues until the end of the line.

```lisp
first = 1   ; first value

second =    ; the key 'second'
"some text" ; the value corresponding to the key 'second'
```

## List

A list is an ordered set of [values](#value) separated by [whitespace](#specifications) and surrounded by `[` and `]`

```lisp
numbers = [1 2 3]   ; a simple list

nested = [          ; a list containing:
    42              ;   a value
    [1 2 3]         ;   a nested list
    (               ;   a map
        first = 1
        second = 2
    )
]
```

## Map

A map is a set of [key / value pairs](#key--value-pair) separated by [whitespace](#specifications) and surrounded by `(` and `)`

```lisp
person = (
    first = John
    last = Doe
    age = 42
    "favorite numbers" = [1 2 3]
)
```

## Key / Value Pair

A [key](#key) / [value](#value) pair is written as `key` `=` `value`

## Key

A key is a [literal](#literal) or [string](#string).

```lisp
key = value             ; keys can be literals
"string key" = [1 2 3]  ; or strings
```

## Value

A value is a [literal](#literal), [string](#string), [list](#list), or [map](#map).  
[Lists](#list) and [maps](#map) can be typed or untyped.

## Literal

A literal is a contiguous set of characters that are not [whitespace](#specifications) or any of `(` `)` `[` `]` `=` `;`  
A literal cannot start with `/` or `"`

```lisp
; some valid literals
123
true
2023/07/01
first-name
don't_worry
quoted"text"

; some invalid literals
some text   ; whitespace
some(thing) ; invalid characters ( )
/value      ; treated as a type name
"text"      ; treated as a string
```

## String

A string begins and ends with `"` and may contain any characters. `"` is escaped as `""`

```lisp
simple = "simple string"
quoted = "some ""quoted"" text"
multi = "multiple
lines
of text"
```

## Type Declaration

A type declaration is a list of [keys](#key), written as `/` `name` `=` `(` keys `)`  
A type name is a [literal](#literal).

```lisp
/person = (first middle last age "favorite number")
```

## Typed List

A typed list is a [list](#list) preceded by `/` `name` or an [inline type](#inline-type).  
The type is applied to any untyped child [lists](#list) and [maps](#map).

```lisp
/point = (x y z)    ; declare type 'point'

points = /point [   ; points is a list of type 'point'
    (1 2 3)
    (4 5 6)
    (7 8 9)
]

nested = /point [   ; nested is a list of type 'point'
    [               ; untyped child list is of type 'point'
        (1 2 3)     ; untyped child maps are of type 'point'
        (4 5 6)
        (7 8 9)
    ]
    (1 3 5)         ; untyped child map is of type 'point'
    /(first last) [ ; type is overridden to an inline type with keys 'first' and 'last'
        (John Doe)  ; untyped child maps use the inline parent type
        (Mary Sue)
    ]
]
```

## Typed Map

A typed map is `/` `name` or an [inline type](#inline-type) followed by `(` values `)`  
[Values](#value) are matched to type [keys](#key) in order.  
A [literal](#literal) value of `_` indicates that the map does not have a value for the corresponding key.  
A typed map can have at most the same number of values as the type has keys.  
A typed map can also contain [key / value pairs](#key--value-pair). These are not considered when matching values to type [keys](#key).

```lisp
/person = (first middle last age)   ; declare type 'person'

owner = /person (John D Doe 42)     ; first = John, middle = D, last = Doe, age = 42

list = /person [
    (John D Doe 42)                 ; first = John, middle = D, last = Doe, age = 42
    (Mary _ Sue 36)                 ; first = Mary, last = Sue, age = 36
    (first = Mary age = 42)         ; first = Mary, age = 42
    (
        Mary                        ; first = Mary
        initial = D                 ; keys / values can be intermixed with values
        _                           ; no value for 'middle'
        Sue                         ; last = Sue
        42                          ; age = 42
        address = "123 address"     ; address = "123 address"
    )
]

inline = /(a b c) (1 2 3)           ; inline type, a = 1, b = 2, c = 3

; invalid due to having more values than keys
invalid = /person (First M Last 50 extra)
```

## Inline Type

An inline type is declared directly prior to a typed [list](#typed-list) or [map](#typed-map) as `/` `(` keys `)`

```lisp
points = /(x y) [
    (1 2)           ; x = 1, y = 2
    (3 4)           ; x = 3, y = 4
]
```

# Changelog

## [0.6.0] 2024-03-03

### Added

* Key / value pairs in typed lists and maps

### Removed

* Explicitly untyped lists and maps

## [0.5.0] 2024-02-27

### Added

* Initial version
