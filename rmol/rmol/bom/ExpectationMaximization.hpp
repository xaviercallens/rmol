#ifndef __RMOL_BOM_EXPECTATION_MAXIMIZATION_HPP
#define __RMOL_BOM_EXPECTATION_MAXIMIZATION_HPP


// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// RMOL
#include <rmol/RMOL_UNCONSTRAINER_Types.hpp>
#include <rmol/RMOL_UTILITY_Types.hpp>

namespace RMOL {

  class ExpectationMaximization {
  public :
    static void unconstrainData 
    (ConstrainedDataHolder_T& ioConstrainedDataHolder, 
     UnconstrainedDataHolder_T& iUnconstrainedDataHolder,
     StoppingCriterion_T& iStoppingCriterion);

    static void expectedValueOfNormallyDistributedConstrainedData
    (ConstrainedDataHolder_T& ioConstrainedDataHolder, 
     Mean_T&, StandardDeviation_T&);

  };
}
#endif // __RMOL_BOM_EXPECTATION_MAXIMIZATION_HPP
