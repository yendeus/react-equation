import { CSSProperties } from 'react'

import { ErrorHandler } from './errorHandler'

export type RenderOptions = {
    errorHandler?: ErrorHandler,
    className?: string,
    style?: CSSProperties,
}
