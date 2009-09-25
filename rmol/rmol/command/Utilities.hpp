#ifndef __RMOL_COMMAND_UTILITIES_HPP
#define __RMOL_COMMAND_UTILITIES_HPP
// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <vector>

namespace RMOL {

  struct Utilities {

    /** Returns the minimum element of a given vector*/
    static void getMinimumElement (double& oMinValue, std::vector<double>&); 

    /** Return mean for the given elements of a vector. */
    static void getMean (double& oMean, std::vector<double>&);

    /** Return standard deviation for the given elements of a vector and  
        precomputed mean. */
    static void getStandardDeviation (double& oSD, std::vector<double>&,
                                      double& iMean);

    /** Return mean & standard deviation for given elements of a vector. */
    static void getMeanAndStandardDeviation (std::vector<double>& ioMean_SD,
                                             std::vector<double>&);

    /** Return the input vector after adding a value. */
    static void addAValueToAVector (std::vector<double>& ioVector, 
                                    double iValue);

    /** Return the input vector after multiplying a value. */
    static void multiplyAValueToAVector (std::vector<double>& ioVector, 
                                         double iValue);

    /** Return first input vector after adding 2nd input vector to it. */
    static void addTwoVectors (std::vector<double>& ioVector, 
                               std::vector<double>& iVector);

    /** Return a string constructed by the elements of a vector. */
    static std::string vectorToString (std::vector<double>& iVector);

  };

}

#endif // __RMOL_COMMAND_UTILITIES_HPP