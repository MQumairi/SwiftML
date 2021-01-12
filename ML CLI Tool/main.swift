//
//  main.swift
//  ML CLI Tool
//
//  Created by Mohammed Alqumairi on 10/01/2021.
//

import Foundation


var m1 : Matrix = Matrix(value: [[4, 2, 6], [2, 1, 5], [3, 11, 4]])
var m2 : Matrix = Matrix(value: [[1, 3, 9], [3, 2, 2], [6, 1, 1]])
var m3 : Matrix = Matrix(value: [[1, 3], [3, 2], [6, 1]])

var m4 : Matrix = Matrix(value: [[1, 2, 3], [4, 5, 6]])
var m5 : Matrix = Matrix(value: [[7, 8], [9, 10], [11, 12]])
var m6 : Matrix = Matrix(value: [[7], [7], [7]])


var v1 : Matrix = Matrix(value: [[1, 2, 3]])
var v2 : Matrix = Matrix(value: [[4], [5], [6]])

var d1 : Matrix = Matrix(value: [[6, 1, 1], [4, -2, 5], [2, 8, 7]])
var d2 : Matrix = Matrix(value: [[1, 3, 2], [-3, -1, -3], [2, 3, 1]])
var d3 : Matrix = Matrix(value: [[-5, 0, -1], [1, 2, -1], [-3, 4, 1]])
var d4 : Matrix = Matrix(value: [[6, 1, 1, 4, 6], [5, 6, 7, 8, 6], [9, 8, 11, 12, 6], [13, 14, 15, 16, 6], [6, 6, 6, 6, 6]])

var i1 : Matrix = Matrix(value: [[3, 0, 2], [2, 0, -2], [0, 1, 1]])

//print(i1.addRow(row: [0, 1, 1], at: 1))
//print(i1.shape)
//print(i1.removeRow(at: 0))
//print(i1.shape)
//print(i1.removeColumn(at: 1))
//print(i1.shape)
//print(i1.addColumn(column: [0, 1, 1], at: 2))

print(m1)
print(m2)

let mJoined = m1.stack(on: m2)
print(mJoined)
print(mJoined.shape)



//let zs = Matrix.zeros(m: 5, n: 3)

//print(m3)
//print(m3.T)
//print(m3)

//print(Matrix.determinant(matrix: d1))
//print(Matrix.determinant(m1: d2, dim: 3))
//print(Matrix.determinant(m1: d3, dim: 3))
//print(Matrix.determinant(m1: d4, dim: 5))

//
//print(Matrix.determinant(m1: Matrix.minorMatrix(m1: d1, row: 0, column: 0), dim: 2))

//var randomM : Matrix = Matrix.random(rows: 3, columns: 5, range: 1...10)
//print(m1, " + ", m2, " = " , m1 + m2)

//print(randomM)
//
//func floorDouble (x: Double) -> Double {
//    return floor(x)
//}
//
//print(randomM.map(function: floorDouble))

//var hugrMatrix = Matrix.zeros(m: 10000, n: 30)

//print(hugrMatrix + 2)




