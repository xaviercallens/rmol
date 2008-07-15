#ifndef __RMOL_BOM_DPOPTIMISER_HPP
#define __RMOL_BOM_DPOPTIMISER_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
#include <rmol/RmolTypes.hpp>

namespace RMOL {

  /** Forward declarations. */
  //class Resource;
  class BucketHolder;
  

  /** Utility methods for the Dynamic Programming algorithms. */
  class DPOptimiser {
  public:
    
    /** 
	Dynamic Programming to compute the cumulative protection levels
	and booking limits (described in the book Revenue Management -
	Talluri & Van Ryzin, p.41-42).
    
    <br>The cabin capacity is used to a double to allow for some overbooking.
     */
    static void optimalOptimisationByDP (const ResourceCapacity_T,
                                         BucketHolder&,
                                         BidPriceVector_T&);
  };
}
#endif // __RMOL_BOM_DPOPTIMISER_HPP