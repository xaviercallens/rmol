#ifndef __RMOL_RMOL_TYPES_HPP
#define __RMOL_RMOL_TYPES_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <vector>
#include <list>

namespace RMOL {

   // ///////// Exceptions ///////////
  class RootException : public std::exception {
  };

  class FileNotFoundException : public RootException {
  };
  
  class NonInitialisedServiceException : public RootException {
  };

  class MemoryAllocationException : public RootException {
  };

  class ObjectNotFoundException : public RootException {
  };

  class DocumentNotFoundException : public RootException {
  };


  // /////////////// Log /////////////
  /** Level of logs. */
  namespace LOG {
    typedef enum {
      CRITICAL = 0,
      ERROR,
      NOTIFICATION,
      WARNING,
      DEBUG,
      VERBOSE,
      LAST_VALUE
    } EN_LogLevel;
  }

  // //////// Type definitions /////////
  /** Define the capacity.
      <br>It is a double, as it allows for overbooking. */
  typedef double ResourceCapacity_T;

  /** Define the Booking Limit.
      <br>It is a double, as it allows for overbooking. */
  typedef double BookingLimit_T;

  /** Define the number of products.*/
  typedef const unsigned int NumberOfProducts_T;

  /** Define the number of products similar to a product.*/
  typedef const unsigned int NumberOfProductsSimilarToAProduct_T;

  /** Define the Bid-Price Vector.
      <br> It is a vector of double. */
  typedef std::vector<double> BidPriceVector_T;

  /** Define the list of EMSR values for the EMSR algorithm. */
  typedef std::vector<double> EmsrValueList_T;

  /** Define the vector of booking limits.
      <br> It is a vector of double. */
  typedef std::vector<double> BookingLimitVector_T;

  /** Define the vector of generated demand (for MC integration use).
      <br> It is a vector of double. */
  typedef std::vector<double> GeneratedDemandVector_T;

  /** Define the holder of the generated demand vectors. */
  typedef std::vector<GeneratedDemandVector_T> GeneratedDemandVectorHolder_T;

  /** Define the sellup probability.*/
  typedef double SellupProbability_T;

  /** Define the sellup probability vector.*/
  typedef std::vector<SellupProbability_T> SellupProbabilityVector_T;

  /** Define the holder of sellup factors (used for computing Q-eq bookings)*/
  typedef std::vector<double> SellupFactorHolder_T;

//   /** Define the historical booking data of a flight date in the order of
//       the classes in the BucketHolder
//       eg. 
//       BucketHolder=[Q;M;B;Y], OrderedHistoricalBookingVector_T=[10;5;0;0] 
//       5 corresponds to bookings of class M of a similar flight */
//   typedef std::vector<double> OrderedHistoricalBookingVector_T;

//   /** Define the holder of historical booking vectors */
//   typedef std::vector<HistoricalBookingHolder> 
//                                              HistoricalBookingHolderHolder_T;

  // /** Define the holder of Q-equivalent booking values*/
  // typedef std::vector<double> HolderOfQEquivalentBookingsPerSimilarFlight_T;

}
#endif // __RMOL_RMOL_TYPES_HPP
