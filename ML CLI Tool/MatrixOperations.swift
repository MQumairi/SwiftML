//
//  MatrixOperations.swift
//  ML CLI Tool
//
//  Created by Mohammed Alqumairi on 10/01/2021.
//

import Foundation

//Addition
func + (matrix: Matrix, scalar: Double) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: +, matrix: matrix, scalar: scalar)
    return outPutMatrix
}

func + (scalar: Double, matrix: Matrix) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: +, matrix: matrix, scalar: scalar, scalarSide: "left")
    return outPutMatrix
}

func + (m1: Matrix, m2: Matrix) -> Matrix {
    let outPutMatrix = Matrix.elewiseOp(op: +, m1: m1, m2: m2)
    return outPutMatrix
}

//Subtrcation
func - (matrix: Matrix, scalar: Double) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: -, matrix: matrix, scalar: scalar)
    return outPutMatrix
}

func - (scalar: Double, matrix: Matrix) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: -, matrix: matrix, scalar: scalar,  scalarSide: "left")
    return outPutMatrix
}

func - (m1: Matrix, m2: Matrix) -> Matrix {
    let outPutMatrix = Matrix.elewiseOp(op: -, m1: m1, m2: m2)
    return outPutMatrix
}

//Multiplication
func * (matrix: Matrix, scalar: Double) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: *, matrix: matrix, scalar: scalar)
    return outPutMatrix
}

func * (scalar: Double, matrix: Matrix) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: *, matrix: matrix, scalar: scalar, scalarSide: "left")
    return outPutMatrix
}

func * (m1: Matrix, m2: Matrix) -> Matrix {
    let outPutMatrix = Matrix.elewiseOp(op: *, m1: m1, m2: m2)
    return outPutMatrix
}

//Division
func / (matrix: Matrix, scalar: Double) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: /, matrix: matrix, scalar: scalar)
    return outPutMatrix
}

func / (scalar: Double, matrix: Matrix) -> Matrix {
    let outPutMatrix = Matrix.scalarOp(op: /, matrix: matrix, scalar: scalar, scalarSide: "left")
    return outPutMatrix
}

func / (m1: Matrix, m2: Matrix) -> Matrix {
    let outPutMatrix = Matrix.elewiseOp(op: /, m1: m1, m2: m2)
    return outPutMatrix
}
