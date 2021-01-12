//
//  Matrix.swift
//  ML CLI Tool
//
//  Created by Mohammed Alqumairi on 10/01/2021.

import Foundation

// Matrix class
class Matrix: CustomStringConvertible, Equatable {
    
    var value: [[Double]]
    var shape: (rows:Int, columns:Int)
    lazy var T: Matrix = self.transpose() //Lazy to not perform the transformation before prop is called
    
    //Initializer
    init(_ value: [[Double]]) {
        try! Matrix.checkMalformation(arr: value)
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
    
    //Returns a matrix equivalent to the transpose of self
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
        try! Matrix.checkShapesDotable(m1: self, m2: m2)
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
    
    //Add a row to the matrix, at the specified position
    func addRow (row: [Double], at: Int) -> Matrix {
        try! Matrix.checkArrayToAddCorrectSize(length1: value[0].count, length2: row.count)
        value.insert(row, at: at)
        shape.rows += 1
        return self
    }
    
    //Remove a row from the matrix, from the specified position
    func removeRow (at: Int) -> Matrix {
        value.remove(at: at)
        shape.rows -= 1
        return self
    }
    
    //Add a column to the matrix, at the  specfied position
    func addColumn (column: [Double], at: Int) -> Matrix {
        try! Matrix.checkArrayToAddCorrectSize(length1: self.shape.rows, length2: column.count)
        for (i, _) in value.enumerated() {
            value[i].insert(column[i], at: at)
        }
        shape.columns += 1
        return self
    }
    
    //Remove a column from the matrix, at the specified position
    func removeColumn (at: Int) -> Matrix {
        for (i, _) in value.enumerated() {
            value[i].remove(at: at)
        }
        shape.columns -= 1
        return self
    }
    
    //Split a Matrix by row at the specifeid position, into two matrices,
    func splitByRow (at: Int) -> (Matrix, Matrix) {
        var arr1 : [[Double]] = []
        var arr2 : [[Double]] = []
        var i = 0
        while i < (at) {
            arr1.append(self.value[i])
            i += 1
        }
        while i < (self.shape.columns) {
            arr2.append(self.value[i])
            i += 1
        }
        return (Matrix(arr1), Matrix(arr2))
    }
    
    //Split a Matrix by column at the specified position, into two matrices
    func splitByColumn (at: Int) -> (Matrix, Matrix) {
        let m1 : Matrix = Matrix.zeros(rows: self.shape.columns, columns: at)
        let m2 : Matrix = Matrix.zeros(rows: self.shape.columns, columns: self.shape.columns - at)
        
        for (i, _) in self.value.enumerated() {
            var j = 0
            var k = 0
            
            while j < (self.shape.columns) {
                if j < at {
                    m1.value[i][j] = self.value[i][j]
                } else {
                    m2.value[i][k] = self.value[i][j]
                    k += 1
                }
                j += 1
            }
        }
        return (m1, m2)
    }
    
    //Join self with another matrix (combine horizontally)
    func join (with: Matrix) -> Matrix {
        try! Matrix.checkRowsEqual(m1: self, m2: with)
        let outputMatrix = self
        for (i, _) in outputMatrix.value.enumerated() {
            for (j, _) in with.value[i].enumerated() {
                outputMatrix.value[i].append(with.value[i][j])
            }
        }
        outputMatrix.shape.columns = with.shape.columns + self.shape.columns
        return outputMatrix
    }
    
    //Stack self ontop of another matrix (combine vertically)
    func stack (on: Matrix) -> Matrix {
        try! Matrix.checkColumnsEqual(m1: self, m2: on)
        let outputMatrix = self
        for (i, _) in on.value.enumerated() {
            outputMatrix.value.append(on.value[i])
        }
        outputMatrix.shape.rows = on.shape.rows + self.shape.rows
        return outputMatrix
    }
    
    //*********************
    //* STATIC FUNCTIONS *
    //*********************

    //Scalar OP... takes an operation, a matrix, and a scalar.
    //Outputs the matrix with that operation applied to all elements using the scalar.
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

    //Elewise OP... takes an operation, and two matrices, and performs the operation on the two matrices elewise
    static func elewiseOp (op: (Double, Double) -> Double, m1: Matrix, m2: Matrix) -> Matrix {
        try! Matrix.checkShapesEqual(m1: m1, m2: m2)
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
    
    //Take an operation and two lists, and performs an operation on corresponding values of the two lists
    static func listOp (op: (Double, Double) -> Double, l1: [Double], l2: [Double]) -> [Double] {
        try! checkArrayEqualSize(l1: l1, l2: l2)
        var outputList : [Double] = []
        for (i, _) in l1.enumerated() {
            outputList.append(op(l1[i], l2[i]))
        }
        return outputList
    }
    
    //Sum a list
    static func sum (l1: [Double]) -> Double {
        return l1.reduce(0, +)
    }
    
    //Sum the values in a matrix
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
        return Matrix(arr)
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
    
    //Given a Matrix, return its determinant
    static func determinant (matrix: Matrix) -> Double {
        try! Matrix.checkMatrixIsSquare(m1: matrix)
        return calcDeterminant(m1: matrix, dim: matrix.shape.rows)
    }
    
    //Does the determinant calculation recursively
    static func calcDeterminant (m1: Matrix, dim: Int, toReturn: Double = 0.0) -> Double {
        //Check that the matix is a square
        try! Matrix.checkMatrixIsSquare(m1: m1)
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
                let minorDeterminant = value * calcDeterminant(m1: minorMatrix, dim: dim-1, toReturn: output)
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
        return output
    }
    
    //Given a matrix, and the row-column coordinates of a value v, create the minor matrix
    //minor matrix is original excluding the row and column that v is in
    static func minorMatrix (m1: Matrix, row: Int, column: Int) -> Matrix {
        var outputValue = m1.value
        outputValue.remove(at: row)
        
        for (i, _) in outputValue.enumerated() {
            outputValue[i].remove(at: column)
        }
        return Matrix(outputValue)
    }
    
    //Given a matrix, output the matrix of minors.
    // - Go through each element
    // - mm = minorMatrix(elementrow, elementcol)
    // - d = determinant(mm)
    // - place d in ouput at position elementrow elementcol
    static func matrixOfMinors (matrix: Matrix) -> Matrix {
        try! Matrix.checkMatrixIsSquare(m1: matrix)
        let outputMatrix = zeros(rows: matrix.shape.rows, columns: matrix.shape.columns)
        for (i, _) in matrix.value.enumerated() {
            for (j, _) in matrix.value[i].enumerated() {
                let mm = minorMatrix(m1: matrix, row: i, column: j)
                var d = determinant(matrix: mm)
                d = d == -0.0 ? 0.0 : d
                outputMatrix.value[i][j] = d
            }
        }
        return outputMatrix
    }
    
    //Given a matrix output the matrix of cofactors.
    // - iterate over every element.
    // - for every second element, multiply it by -1
    static func matrixOfCofactors (matrix: Matrix) -> Matrix {
        let outputMatrix = matrix
        for (i, _) in matrix.value.enumerated() {
            for (j, _) in matrix.value[i].enumerated() {
                if (i % 2 == 0 && j % 2 == 1 || i % 2 == 1 && j % 2 == 0) {
                    outputMatrix.value[i][j] = matrix.value[i][j] * -1
                }
            }
        }
        return outputMatrix
    }
    
    //Given a matrix, output its inverse
    // - calculate matrixOfMinors
    // - calculate matrixOfCofactors
    // - transpose
    // - multiple this result with 1/d, where d is the determinant of the input matrix
    static func inverse (matrix: Matrix) -> Matrix {
        try! Matrix.checkMatrixIsSquare(m1: matrix)
        let mm = matrixOfMinors(matrix: matrix)
        let mc = matrixOfCofactors(matrix: mm)
        let mcT = mc.T
        let d = determinant(matrix: matrix)
        let outputMatrix = mcT * (1 / d)
        return outputMatrix
    }
        
    //*****************
    //* MATRIX ERRORS *
    //*****************
    
    enum MatrixError: Error {
        case matrixMalformed
        case shapeMismatch(matrixShape:(Int, Int), expectedShape:(Int, Int))
        case arrayLengthMismatch(arrayLength: Int, expectedLength: Int)
        case notSquareMatrix(matrixShape:(Int, Int))
        case rowsMismatch(rowsLength: Int, expectedLength: Int)
        case columnsMismatch(columnLength: Int, expectedLength: Int)
    }
    
    //Checks that all inner arrays, in a 2D array of Doubles, are of equal size. Else throws error.
    static func checkMalformation (arr: [[Double]]) throws {
        if (arr.count == 0) {
            return
        }
        let sizeOfFirstArr = arr[0].count
        for (i, _) in arr.enumerated() {
            if (arr[i].count != sizeOfFirstArr) {
                print("The inputted array is malformed. All rows need to be of equal length.")
                throw MatrixError.matrixMalformed
            }
        }
    }
    
    //Checks that two matrix shapes are equal, or that the second is a vector. Else throws error.
    static func checkShapesEqual (m1: Matrix, m2: Matrix) throws {
        if (m1.shape != m2.shape && m2.shape.columns != 1) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: m1.shape)
        }
    }
    
    //Checks that two matrix shapes are dotable (i.e. a x n and n x b). Else throws error.
    static func checkShapesDotable (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.columns != m2.shape.rows) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: (m1.shape.columns, m2.shape.columns))
        }
    }
    
    //Checks that two matrix shapes are reversed (i.e. m x n and n x m). Else throws error.
    static func checkShapesReversed (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.rows != m2.shape.columns || m1.shape.columns != m2.shape.rows) {
            print("Matrix shapes mismatch. First matrix has shape ", m1.shape, ", whereas second has shape ", m2.shape)
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: (m1.shape.columns, m1.shape.rows))
        }
    }
    
    //Checks that two arrays are of equal size. Else throws error.
    static func checkArrayEqualSize (l1: [Double], l2: [Double]) throws {
        if (l1.count != l2.count) {
            print("Aarrays are not of equal length. First array has length ", l1.count, ", whereas second has length ", l2.count)
            throw MatrixError.arrayLengthMismatch(arrayLength: l2.count, expectedLength: l1.count)
        }
    }
    
    //Check if the two numbers representing the length of an array are the same. Else , throws error
    static func checkArrayToAddCorrectSize (length1: Int, length2: Int) throws {
        if (length1 != length2) {
            print("The row or column you're trying to add is of incorrect length", length2, "expected", length1)
            throw MatrixError.arrayLengthMismatch(arrayLength: length2, expectedLength: length1)
        }
    }
    
    //Checks that two matrices have the same number of rows. Else throws error.
    static func checkRowsEqual (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.rows != m2.shape.rows) {
            print("Matrix have different number of rows. First matrix has", m1.shape.rows, "rows, whereas second has", m2.shape.rows, "rows")
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: m1.shape)
        }
    }
    
    //Checks that two matrices have the same number of columns. Else throws error.
    static func checkColumnsEqual (m1: Matrix, m2: Matrix) throws {
        if (m1.shape.columns != m2.shape.columns) {
            print("Matrix have different number of columns. First matrix has", m1.shape.columns, "rows, whereas second has", m2.shape.columns, "columns")
            throw MatrixError.shapeMismatch(matrixShape: m2.shape, expectedShape: m1.shape)
        }
    }
    
    //Checks that matrix is a square
    static func checkMatrixIsSquare (m1: Matrix) throws {
        if (m1.shape.rows != m1.shape.columns){
            print("Matrix not a square. Has shape ", m1.shape)
            throw MatrixError.notSquareMatrix(matrixShape: m1.shape)
        }
    }
    
    //***********************
    //* PROTOCOL COMFORMING *
    //***********************
    
    //Conforming to Equitable Protocol
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.value == rhs.value
    }
}
