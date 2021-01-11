//
//  Matrix.swift
//  ML CLI Tool
//
//  Created by Mohammed Alqumairi on 10/01/2021.
//

//TODO:
// - determinant
// - matrix of minors
// - matrix of cofactors
// - inverse

// - add Row
// - remove Row
// - add Column
// - remove Column
// - split Matrix by row
// - split Matrix by column

import Foundation

// Matrix class
class Matrix: CustomStringConvertible, Equatable {
    
    var value: [[Double]]
    var shape: (rows:Int, columns:Int)
    lazy var T: Matrix = self.transpose() //Lazy to not perform the transformation before prop is called
    
    //Initializer
    init(value: [[Double]]) {
        let firstRowLength = value[0].count
        var malFormed = false
        for row in value {
            if (row.count != firstRowLength) {
                malFormed = true
            }
        }
        if (malFormed) {
            print("CAUTION: this Matrix is malformed.")
        }
        self.value = value
        self.shape = (self.value.count, self.value[0].count)
    }
    //Description--- to override printing of the matrix
    var description: String {
        var desc = "\n"
        var maxSpacing = String(value[0][0]).count
        var maxLastItemOnRow = String(value[0][self.shape.columns - 1]).count
        //Calculate the max character length of string representation of each value (for spacing purposes)
        for (i, _) in value.enumerated() {
            for (j, _) in value[i].enumerated() {
                let lengthOfValue = String(value[i][j]).count
                if (lengthOfValue > maxSpacing) {
                    maxSpacing = lengthOfValue
                }
            }
            //Length of string representation of last item in row (for spacing purposes)
            let lastItemLength = String(value[i][self.shape.columns - 1]).count
            if (maxLastItemOnRow < lastItemLength) {
                maxLastItemOnRow = lastItemLength
            }
        }
        for (i, _) in value.enumerated() {
            desc += "["
            for (j, _) in value[i].enumerated() {
                let lengthOfValue = String(value[i][j]).count
                desc += String(value[i][j])
                if (j != value[i].count - 1) {
                    desc += String.init(repeating: " ", count: (maxSpacing - lengthOfValue + 2))
                } else {
                    if (lengthOfValue < maxLastItemOnRow) {
                        desc += String.init(repeating: " ", count: (maxLastItemOnRow - lengthOfValue))
                    }
                }
            }
            desc += "]\n"
        }
        return desc
    }
    
    //Takes in a function f that returns a double, maps f to the current matrix elewise
    func map (function: (Double) -> Double) -> Matrix {
        for (i, _) in value.enumerated() {
            for (j, _) in value[i].enumerated() {
                self.value[i][j] = function(value[i][j])
            }
        }
        return self
    }
    
    //Returns a matrix equivalent to the matrix of self
    func transpose () -> Matrix {
        let outputMatrix = Matrix.zeros(rows: self.shape.columns, columns: self.shape.rows)
        for (i, _) in value.enumerated() {
            for (j, _) in value[i].enumerated() {
                outputMatrix.value[j][i] = value[i][j]
            }
        }
        return outputMatrix
    }
    
    //self.dot(m2) results in the dot product of self with m2 (where self and m2 are matrices of dotable dimensions)
    func dot (m2: Matrix) -> Matrix {
        try! Matrix.shapesDotable(m1: self, m2: m2)
        let outputMatrix = Matrix.zeros(rows: self.shape.rows, columns: m2.shape.columns)
        let m2Transpose = m2.T
        for (i, _) in value.enumerated() {
            for (j, _) in m2Transpose.value.enumerated() {
                let productOfRows = Matrix.listOp(op: *, l1: value[i], l2: m2Transpose.value[j])
                outputMatrix.value[i][j] = Matrix.sum(l1: productOfRows)
            }
        }
        return outputMatrix
        
    }
    
    //Scalar OP... takes an operation, a matrix, and a scalar. Outputs the matrix with that operation applied to all elements using the scalar.
    static func scalarOp (op: (Double, Double) -> Double, matrix: Matrix, scalar: Double, scalarSide: String="right") -> Matrix {
        let outputMatrix = Matrix.zeros(rows: matrix.shape.rows, columns: matrix.shape.columns)
        for (i, _) in matrix.value.enumerated() {
            for (j, _) in matrix.value[i].enumerated() {
                if(scalarSide=="right") {
                    outputMatrix.value[i][j] = op(matrix.value[i][j], scalar)
                } else if (scalarSide=="left") {
                    outputMatrix.value[i][j] = op(scalar, matrix.value[i][j])
                }
            }
        }
        return outputMatrix
    }

    //Elewise OP... takes an operation, and two matrices, and performs an elewise multiplication on them
    static func elewiseOp (op: (Double, Double) -> Double, m1: Matrix, m2: Matrix) -> Matrix {
        try! Matrix.shapesEqual(m1: m1, m2: m2)
        let outputMatrix = Matrix.zeros(rows: m1.shape.rows, columns: m1.shape.columns)
        //If the second matrix is a vector...
        if (m2.shape.columns == 1) {
            for(i, _) in m1.value.enumerated() {
                //Broadcast it
                for (j, _) in m1.value[i].enumerated() {
                    outputMatrix.value[i][j] = op(m1.value[i][j], m2.value[i][0])
                }
            }
        //Else, neither matrix is a vector
        } else {
            //So perform the opertion eleWise
            for(i, _) in m1.value.enumerated() {
                for (j, _) in m2.value[i].enumerated() {
                    outputMatrix.value[i][j] = op(m1.value[i][j], m2.value[i][j])
                }
            }
        }
        return outputMatrix
    }
    
    static func listOp (op: (Double, Double) -> Double, l1: [Double], l2: [Double]) -> [Double] {
        try! arrayEqualSize(l1: l1, l2: l2)
        var outputList : [Double] = []
        for (i, _) in l1.enumerated() {
            outputList.append(op(l1[i], l2[i]))
        }
        return outputList
    }
    
    static func sum (l1: [Double]) -> Double {
        return l1.reduce(0, +)
    }
    
    static func sum (m1: Matrix) -> Double {
        var total = 0.0
        for (i, _) in m1.value.enumerated() {
            let summedRows = sum(l1: m1.value[i])
            total += summedRows
        }
        return total
    }
    
    //Takes in an m and an n, outputs a matrix of zeros of shape mxn
    static func zeros (rows: Int, columns: Int) -> Matrix {
        let zerosArrN = Array(repeating: Double(0.0), count: columns)
        var arr : [[Double]] = []
        var i = 1
        while i <= rows {
            arr.append(zerosArrN)
            i+=1
        }
        return Matrix(value: arr)
    }
    
    //Takes in an m and an n, (and optionally, a range) outputs a matrix of random values within that range
    static func random (rows: Int, columns: Int, range: ClosedRange<Double> = 0...1) -> Matrix {
        let randomArr = zeros(rows: rows, columns: columns)
        for (i, _) in randomArr.value.enumerated() {
            for (j, _) in randomArr.value[i].enumerated() {
                let randomNumb = Double.random(in: range)
                randomArr.value[i][j] = randomNumb
            }
        }
        return randomArr
    }
    
//    func determinant () -> Double {
//        try! Matrix.matrixIsSquare(m1: self)
//        let dim = self.shape.rows
//        var output = 0.0
//        let inputMatrix = self.value
//        //If 2x2 matrix
//        if (dim == 2) {
//            output = (inputMatrix[0][0] * inputMatrix[1][1]) - (inputMatrix[0][1] * inputMatrix[1][0])
//            return output
//        } else {
//            //Else
//            let dimExtra = dim - 2
//            var arrOfMinorDeterminants = []
//
//        }
//    }
    
    static func determinant (m1: Matrix, dim: Int, toReturn: Double = 0.0) -> Double {
        //Check that the matix is a square
        try! Matrix.matrixIsSquare(m1: m1)
        //Initialize Output
        var output = toReturn
        //Base case: If 2x2 Matrix
        if(dim == 2) {
            output = (m1.value[0][0] * m1.value[1][1]) - (m1.value[0][1] * m1.value[1][0])
        }
        //Else: Recursive case
        else {
            var arrOfMinorDeterminants: [Double] = []
            for (i, value) in m1.value[0].enumerated() {
                let minorMatrix = Matrix.minorMatrix(m1: m1, row: 0, column: i)
//                if (additionsToOutput % 2 == 0) {
//                    output += value * determinant(m1: minorMatrix, dim: dim-1, toReturn: output, additionsToOutput: additionsToOutput + 1)
//                } else {
//                    output -= value * determinant(m1: minorMatrix, dim: dim-1, toReturn: output, additionsToOutput: additionsToOutput + 1)
//                }
                let minorDeterminant = value * determinant(m1: minorMatrix, dim: dim-1, toReturn: output)
                arrOfMinorDeterminants.append(minorDeterminant)
            }
            for (i, value) in arrOfMinorDeterminants.enumerated() {
                if (i % 2 == 0) {
                    output += value
                } else {
                    output -= value
                }
            }
        }
//        print(output)
        return output
    }
    
    static func minorMatrix (m1: Matrix, row: Int, column: Int) -> Matrix {
        var outputValue = m1.value
        outputValue.remove(at: row)
        
        for (i, _) in outputValue.enumerated() {
            outputValue[i].remove(at: column)
        }
        return Matrix(value: outputValue)
    }
        
    //Takes a function f (that takes one or more doubles, and returns a double), and a Matrix.
    //Maps f to each value in the matrix
    enum MatrixError: Error {
        case shapeMismatch(matrixShape:(Int, Int), expectedShape:(Int, Int))
        case arrayLengthMismatch(arrayLength: Int, expectedLength: Int)
        case notSquareMatrix(matrixShape:(Int, Int))
    }
    
    //Checks that two matrix shapes are equal, or that the second is a vector. Else throws error.
    static func shapesEqual (m1: Matrix, m2: Matrix) throws {
        if (m1.shape != m2.shape && m2.shape.columns != 1) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: m1.shape)
        }
    }
    
    //Checks that two matrix shapes are dotable (i.e. a x n and n x b). Else throws error.
    static func shapesDotable (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.columns != m2.shape.rows) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: (m1.shape.columns, m2.shape.columns))
        }
    }
    
    //Checks that two matrix shapes are reversed (i.e. m x n and n x m). Else throws error.
    static func shapesReversed (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.rows != m2.shape.columns || m1.shape.columns != m2.shape.rows) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: (m1.shape.columns, m1.shape.rows))
        }
    }
    
    //Checks that two arrays are of equal size. Else throws error.
    static func arrayEqualSize (l1: [Double], l2: [Double]) throws {
        if (l1.count != l2.count) {
            print("Aarrays are not of equal length. First array has length ", l1.count, ", whereas second has length ", l2.count)
            throw MatrixError.arrayLengthMismatch(arrayLength: l2.count, expectedLength: l1.count)
        }
    }
    
    //Checks that matrix is a square
    static func matrixIsSquare (m1: Matrix) throws {
        if (m1.shape.rows != m1.shape.columns){
            print("Matrix not a square. Has shape ", m1.shape)
            throw MatrixError.notSquareMatrix(matrixShape: m1.shape)
        }
    }
    
    //Conforming to Equitable Protocol
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.value == rhs.value
    }
}
