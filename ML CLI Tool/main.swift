//
//  main.swift
//  ML CLI Tool
//
//  Created by Mohammed Alqumairi on 10/01/2021.
//

import Foundation

var m1 = Matrix([[4, 2, 6], [2, 1, 5], [3, 11, 4]])
var m2 = Matrix([[1, 3, 9], [3, 2, 2], [6, 1, 1]])
var m3 = Matrix([[1, 3], [3, 2], [6, 1]])

var m4 = Matrix([[1, 2, 3], [4, 5, 6]])
var m5 = Matrix([[7, 8], [9, 10], [11, 12]])
var m6 = Matrix([[7], [7], [7]])

var v1 = Matrix([[1, 2, 3]])
var v2 = Matrix([[4], [5], [6]])

var d1 = Matrix([[6, 1, 1], [4, -2, 5], [2, 8, 7]])
var d2 = Matrix([[1, 3, 2], [-3, -1, -3], [2, 3, 1]])
var d3 = Matrix([[-5, 0, -1], [1, 2, -1], [-3, 4, 1]])
var d4 = Matrix([[6, 1, 1, 4, 6], [5, 6, 7, 8, 6], [9, 8, 11, 12, 6], [13, 14, 15, 16, 6], [6, 6, 6, 6, 6]])

var i1 = Matrix([[3, 0, 2], [2, 0, -2], [0, 1, 1]])

print(m1)
print(m2)

let mJoined = m1.stack(on: m2)
print(mJoined)
print(mJoined.shape)
