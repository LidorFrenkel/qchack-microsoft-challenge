
namespace GroverInsuranceSeller {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Preparation;
    
    //The input_DB is a matrix, each array represents a user with his characteristics.
    // The characteristics are [age, number of children, salary in K, a number from 1 to 10 which represent the health condition]
    // In order to "pass", the user should have at least 2 characteristis out of the 4:
    // 1) His age above 30
    // 2) He have more than 2 kids
    // 3) His salary is more than 20K a month
    // 4) His health state is above 7
    @EntryPoint()
    operation start () : Unit{
        let input_db=[[24,2,30,8],[31,1,18,6],[26,3,22,6],[21,0,15,9]];
        let size= Length(input_db);
        mutable A = [0,0,0,0];
        mutable B = [0,0,0,0];
        mutable C = [0,0,0,0];
        mutable D = [0,0,0,0];
        mutable db=[A,B,C,D];
        //now we will check each of the parameters and create new array which decide whether he passes in each paramether or not
        for i in 0.. Length(input_db)-1 {
            if input_db[i][0]>30{
				set db w/= i <- [1,db[i][1],db[i][2],db[i][3]]  ;
            }
            if input_db[i][1]>2{
				set db w/= i <- [db[i][0],1,db[i][2],db[i][3]]  ;
            }
            if input_db[i][2]>20{
				set db w/= i <- [db[i][0],db[i][1],1,db[i][3]]  ;
            }
            if input_db[i][3]>7{
				set db w/= i <- [db[i][0],db[i][1],db[i][2],1]  ;
            }
        }
           Message($"The input_DB is a matrix, each array represents a user with his characteristics.");
		   Message($" characteristics are [age, number of children, salary in K, a number from 1 to 10 which represent the health condition");
		   Message($" In order to pass, the user should have at least 2 characteristis out of the 4:");
		   Message($" 1) His age above 30");
		   Message($" 2) He have more than 2 kids");
		   Message($" 3) His salary is more than 20K a month");
		   Message($" 4) His health state is above 7");
           Message($"");
           Message($"The persons we have in our data base are:");
           Message($" {input_db}");
           Message($"So, we can see that the person in place 0 and the person in place 2 are potential customers for the insurance");
           Message($"");
           Message($"After checking the characteristics we will get the matrix:");
           Message($"{db}");
           Message($"Now let's run the Grover's algorithm and see the results");
           Message($"");
        FactorizeWithGrovers(db);
    }


    operation FactorizeWithGrovers(number : Int[][]) : Unit {

        // Define the oracle that for the factoring problem.
        let markingOracle = MarkDivisor(number, _, _);
        let phaseOracle = ApplyMarkingOracleAsPhaseOracle(markingOracle, _);
        // Bit-size of the number to factorize.
        let size = BitSizeI(Length(number[0]));
        // Estimate of the number of solutions.
        let nSolutions = 1;
        // The number of iterations can be computed using the formula.
        let nIterations = Round(PI() / 4.0 * Sqrt(IntAsDouble(size) / IntAsDouble(nSolutions)));

                // Initialize the register to run the algorithm
        use (register, output) = (Qubit[size], Qubit());
        mutable isCorrect = false;
        mutable answer = 0;
        // Use a Repeat-Until-Succeed loop to iterate until the solution is valid.
        repeat {
            RunGroversSearch(register, phaseOracle, nIterations);
            let res = MultiM(register);
            set answer = BoolArrayAsInt(ResultArrayAsBoolArray(res));
            // Check that if the result is a solution with the oracle.
            markingOracle(register, output);
            if MResetZ(output) == One and answer < Length(number[0]) {
                set isCorrect = true;
            }
            ResetAll(register);
        } until isCorrect;
        Message($"The place in the array of the potential customer is :");
        
        Message($"$$$$$$$");
        Message($"$  {answer}  $");
        Message($"$$$$$$$");
	}

    
    operation MarkDivisor (
        dividend : Int[][],
        divisorRegister : Qubit[],
        target : Qubit
    ) : Unit is Adj+Ctl {
        let size = BitSizeI(Length(dividend[0]));
        use (dividendQubits, resultQubits) = (Qubit[size], Qubit[size]);
        let xs = LittleEndian(dividendQubits);
        let ys = LittleEndian(divisorRegister);
        let result = LittleEndian(resultQubits);
        for i in 0 .. size{
            if (dividend[i][0] + dividend[i][1] + dividend[i][2] + dividend[i][3]) >1{
                    within{
            ApplyXorInPlace(Length(dividend[i]), xs);
        }
        apply{
            let Pattern1 = ControlledOnInt (i,X);
            Pattern1 (divisorRegister,target);
        }
	}
        }

    }

    operation PrepareUniformSuperpositionOverDigits(digitReg : Qubit[]) : Unit is Adj + Ctl {
        PrepareArbitraryStateCP(ConstantArray(10, ComplexPolar(1.0, 0.0)), LittleEndian(digitReg));
    }

    operation ApplyMarkingOracleAsPhaseOracle(
        markingOracle : (Qubit[], Qubit) => Unit is Adj,
        register : Qubit[]
    ) : Unit is Adj {
        use target = Qubit();
        within {
            X(target);
            H(target);
        } apply {
            markingOracle(register, target);
        }
    }

    operation RunGroversSearch(register : Qubit[], phaseOracle : ((Qubit[]) => Unit is Adj), iterations : Int) : Unit {
        ApplyToEach(H, register);
        for _ in 1 .. iterations {
            phaseOracle(register);
            ReflectAboutUniform(register);
        }
    }

    operation ReflectAboutUniform(inputQubits : Qubit[]) : Unit {
        within {
            ApplyToEachA(H, inputQubits);
            ApplyToEachA(X, inputQubits);
        } apply {
            Controlled Z(Most(inputQubits), Tail(inputQubits));
        }
    }
}