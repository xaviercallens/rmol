#ifndef __RMOL_COMMAND_OPTIMISER_HPP
#define __RMOL_COMMAND_OPTIMISER_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
#include <rmol/RmolTypes.hpp>

namespace RMOL {

  /** Forward declarations. */
  //class Resource;
  class BucketHolder;

  /** Class wrapping the optimisation algorithms. */
  class Optimiser {
  public:
    
    /** 
	Monte Carlo Integration algorithm.
	<br>Calculate the optimal protections for the set of buckets/classes
	given in input, and update those buckets accordingly.
	<br>The Monte Carlo Integration algorithm (see The Theory and 
	Practice of Revenue Management, by Kalyan T. Talluri and 
	Garret J. van Ryzin, Kluwer Academic Publishers, for the details) 
	is used. Hence, K is the number of random draws to perform.
	100 is a minimum for K, as statistics must be drawn from those
	random generations.
	<br>The cabin capacity is used to a double to allow for some
	overbooking.
     */
    static void optimalOptimisationByMCIntegration (const int K, 
						    const ResourceCapacity_T,
						    BucketHolder&);
  };
}
#endif // __RMOL_COMMAND_OPTIMISER_HPP
