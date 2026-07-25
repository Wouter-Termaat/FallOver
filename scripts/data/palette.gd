class_name Palette
extends RefCounted

## The Fall Over brand palette. PRD §8.4.
##
## Every colour in the game comes from here — including grey-box placeholders.
## Never write a literal colour anywhere else. If a colour you need isn't in
## this list, that's a design decision for Wouter, not a value to invent.
##
## Usage: Palette.DARK_GREEN

const YELLOW: Color = Color("e1b122")
const LIGHT_YELLOW: Color = Color("ffdc74")
const DARK_BLUE: Color = Color("3185a9")
const LIGHT_BLUE: Color = Color("75b1cb")
const DARK_RED: Color = Color("ab2a2a")
const LIGHT_RED: Color = Color("eb5d5d")
const DARK_GREEN: Color = Color("478026")
const LIGHT_GREEN: Color = Color("82ba61")
const BLACK: Color = Color("313336")
const GREY: Color = Color("c6c6c6")
const WHITE: Color = Color("f9f6f0")

## Grey-box role assignments. PRD §8.3.
## These are what each game element looks like before real art exists.

const STARTER_BLOCK: Color = DARK_GREEN
const FINISH: Color = DARK_RED
const STANDARD_BLOCK: Color = DARK_BLUE
const LONG_BLOCK: Color = YELLOW
const TERRAIN: Color = LIGHT_GREEN
const WATER: Color = LIGHT_BLUE
const INVALID_PLACEMENT: Color = LIGHT_RED
