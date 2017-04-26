#------------------------------------------------------------------------------
# Entry
#------------------------------------------------------------------------------

main -> _ level6 _
        {% ([ ,value, ]) => value %}


#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

@{% function nested(d) { return d[0][0] }%}

@{% function operator([a, ,operator, ,b]) { return {type: 'operator', operator, a, b }} %}

argList[X] -> $X (_ "," _ $X):*
        {% ([[first], rest]) => [first, ...rest.map((a) => a[3][0] )] %}

vector -> "[" _ argList[level5NoMatrix] _ "]"
        {% ([ , ,args, , ]) => args %}


#------------------------------------------------------------------------------
# Tree
#------------------------------------------------------------------------------

# level1-----------------------------------------------------------------------

operand -> number
        {% ([value]) => ({ type: 'number', value }) %}
    | name
        {% ([name]) => ({ type: 'variable', name }) %}
    | "∞"
        {% () => ({ type: 'infinity' }) %}

matrix -> vector
        {% ([values]) => ({ type: 'matrix', n: 1, m: values.length, values: values.map((v) => [v]) }) %}
    | "[" _ (vector _ {% id %}):+ "]"
        {% ([ , ,values, , ], location, reject) => {
            const m = values.length
            const n = values[0].length
            if (values.some((v) => v.length !== n)) {
                return reject
            }

            return {type: 'matrix', n, m, values }
        } %}

function -> name "(" _ argList[level5] _ ")"
        {% ([name, , ,args, , ]) => ({type: 'function', name, args }) %}

block -> "(" _ level5 _ ")"
        {% ([ , ,child, , ]) => ({ type: 'block', child }) %}

# level2-----------------------------------------------------------------------

exponent -> level1 _ "^" _ level2
        {% operator %}

# level3-----------------------------------------------------------------------

# Division separated from multiplication to ensure logical display using fractions. Mathemathically this makes no difference.
# Ensures "2*3/4" is grouped as "2 * 3/4" instead of "2*3 / 4" (the latter would require "(2*3)/4")
division -> level3 _ "/" _ level2
        {% operator %}

# level4-----------------------------------------------------------------------

multiDiv -> level4 _ [÷* ] _ level3
        {% operator %}

# level5-----------------------------------------------------------------------

addSub -> level5 _ [±+-] _ level4
        {% operator %}

negative -> "-" _ level4
        {% ([ , ,value]) => ({ type: 'negative', value }) %}

plusminus -> "±" _ level4
        {% ([ , ,value]) => ({ type: 'plusminus', value }) %}

# level6-----------------------------------------------------------------------

comparison -> level6 _ [=<>≤≥≈] _ level5
        {% ([a, , comparison, ,b]) => ({ type: 'comparison', comparison, a, b }) %}


#------------------------------------------------------------------------------
# Groups
#------------------------------------------------------------------------------

level1 -> (operand | matrix | function | block)
        {% nested %}
level2 -> (operand | matrix | function | block | exponent)
        {% nested %}
level3 -> (operand | matrix | function | block | exponent | division)
        {% nested %}
level4 -> (operand | matrix | function | block | exponent | division | multiDiv)
        {% nested %}
level5 -> (operand | matrix | function | block | exponent | division | multiDiv | addSub | negative | plusminus)
        {% nested %}
level6 -> (operand | matrix | function | block | exponent | division | multiDiv | addSub | negative | plusminus | comparison)
        {% nested %}

# Used to ensure a matrix cannot be a direct child of a matrix
level5NoMatrix -> (operand | function | block | exponent | division | multiDiv | addSub | negative | plusminus)
        {% nested %}


#------------------------------------------------------------------------------
# Base
#------------------------------------------------------------------------------

# Whitespace
_ -> [\s]:*
        {% () => null %}

integer -> [0-9]:+
        {% ([chars]) => chars.join('') %}

number -> integer
        {% id %}
    | integer "." integer
        {% ([integer, , fraction]) => `${integer}.${fraction}` %}

# Chars allowed for identifiers
# English letters                       A-Za-z
# Modified latin letters (skip math)    \u00C0-\u00D6\u00D8-\u00F6\u00F8-\u01BF
# Greek letters                         \u0391-\u03c9
# Special symbols                       '"%‰°

letter -> [A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u01BF\u0391-\u03c9'"%‰°]
        {% id %}

alphanum -> letter
        {% id %}
    | [0-9]
        {% id %}

word -> alphanum:*
        {% ([chars]) => chars.join('') %}

# Name should always start with a letter
name -> letter word
        {% ([first, rest]) => first + rest %}
    | letter word ("_" word):+
        {% ([first, rest, indices]) => first + rest + indices.map(([separator, word]) => separator + word).join('') %}