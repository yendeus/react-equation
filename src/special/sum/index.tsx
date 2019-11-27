import React from 'react'
import { EquationNodeFunction } from 'equation-parser'

import { Rendering } from '../../Rendering'

import { render } from '../../render'

const iconSize = 1.8
const fontFactor = 0.8

const styles = {
    wrapper: {
        display: 'inline-block',
    },

    block: {
        display: 'inline-block',
        verticalAlign: 'top',
        textAlign: 'center' as const,
    },

    icon: {
        display: 'block',
        lineHeight: 0.8,
        fontSize: '2.25em',
        padding: '0 0.1em',
        top: '1px',
    },

    small: {
        display: 'block',
        fontSize: `${fontFactor * 100}%`,
    },
}

export default function sum({args: [variable, start, end, expression]}: EquationNodeFunction) {
    const top = render(end)
    const bottom = render({
        type: 'equals',
        a: variable,
        b: start,
    })
    const block = {
        type: Sum,
        props: { top, bottom },
        aboveMiddle: iconSize / 2 + top.height * fontFactor,
        belowMiddle: iconSize / 2 + bottom.height * fontFactor,
    }
    const rendering = render(wrapParenthesis(expression), false, block)
    return {
        type: 'span',
        props: { style: styles.wrapper },
        aboveMiddle: rendering.aboveMiddle,
        belowMiddle: rendering.belowMiddle,
        children: rendering.elements,
    }
}

function Sum({ top, bottom, style }: { top: Rendering, bottom: Rendering, style: React.CSSProperties}) {
    return (
        <span style={{ ...styles.block, ...style }}>
            <span style={{ height: `${top.height}em`, ...styles.small }}>{top.elements}</span>
            <span style={styles.icon}>Σ</span>
            <span style={{ height: `${bottom.height}em`, ...styles.small }}>{bottom.elements}</span>
        </span>
    )
}

function wrapParenthesis(tree: EquationNode): EquationNode {
    if (canStandAlone(tree)) {
        return tree
    } else {
        return {
            type: 'block',
            child: tree,
        }
    }
}

function canStandAlone(tree: EquationNode): boolean {
    return tree.type === 'variable' ||
        tree.type === 'number' ||
        tree.type === 'block' ||
        tree.type === 'function' ||
        tree.type === 'matrix' ||
        tree.type === 'divide-fraction' ||
        tree.type === 'power' ||
        (tree.type === 'negative' && canStandAlone(tree.value))
}