// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// GSL Random Number Generation (GSL Reference Manual, version 1.7, Chapter 19)
#include <gsl/gsl_cdf.h>
#include <gsl/gsl_randist.h>
// C
#include <assert.h>
#include <math.h>
// STL
#include <iostream>
#include <iomanip>
#include <cmath>
// RMU
#include <rmol/bom/HistoricalBookingHolder.hpp>
#include <rmol/bom/HistoricalBookingHolderHolder.hpp>

namespace RMOL {

  // //////////////////////////////////////////////////////////////////
  HistoricalBookingHolderHolder::HistoricalBookingHolderHolder () {
  }

  // //////////////////////////////////////////////////////////////////
  HistoricalBookingHolderHolder::~HistoricalBookingHolderHolder () {
    _historicalBookingHolderHolder.clear();
  }

  // //////////////////////////////////////////////////////////////////
  const int HistoricalBookingHolderHolder::getNumberOfSimilarFlights () 
    const {
    return _historicalBookingHolderHolder.size();
  }

//   // //////////////////////////////////////////////////////////////////
//   const short HistoricalBookingHolderHolder::getNumberOfUncensoredData () const {
//     short lResult = 0;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const bool lFlag = _historicalBookingHolderHolder.at(ite).getFlag ();
//       if (lFlag == false) {
//         ++ lResult;
//       }
//     }

//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::
//   getNumberOfUncensoredBookings () const {
//     double lResult = 0;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const HistoricalBooking lHistorialBooking =
//         _historicalBookingHolderHolder.at(ite);
//       const bool lFlag = lHistorialBooking.getFlag ();
//       if (lFlag == false) {
//         const double lBooking = 
//           lHistorialBooking.getNumberOfBookings ();
//         lResult += lBooking;
//       }
//     }

//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::getUncensoredStandardDeviation
//   (const double iMeanOfUncensoredBookings, const short iNumberOfUncensoredData)
//     const {
      
//     double lResult = 0;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const bool lFlag = _historicalBookingHolderHolder.at(ite).getFlag ();
//       if (lFlag == false) {
//         const HistoricalBooking lHistorialBooking =
//           _historicalBookingHolderHolder.at(ite);
          
//         const double lBooking =
//           lHistorialBooking.getNumberOfBookings ();
          
//         lResult += (lBooking - iMeanOfUncensoredBookings)
//           * (lBooking - iMeanOfUncensoredBookings);
//       }
//     }
//     lResult /= (iNumberOfUncensoredData - 1);
//     lResult = sqrt (lResult);
      
//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::getMeanDemand () const {
//     double lResult = 0;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const HistoricalBooking lHistorialBooking =
//         _historicalBookingHolderHolder.at(ite);
        
//       const double lDemand =
//         lHistorialBooking.getUnconstrainedDemand ();
        
//       lResult += static_cast<double>(lDemand);
//     }

//     lResult /= lSize;

//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::getStandardDeviation
//   (const double iMeanDemand) const {
//     double lResult = 0;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const HistoricalBooking lHistorialBooking =
//         _historicalBookingHolderHolder.at(ite);
        
//       const double lDemand =
//         lHistorialBooking.getUnconstrainedDemand ();
        
//       const double lDoubleDemand = static_cast<double> (lDemand);
//       lResult += (lDoubleDemand - iMeanDemand) * (lDoubleDemand - iMeanDemand);
//     }

//     lResult /= (lSize - 1);

//     lResult = sqrt (lResult);

//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const std::vector<bool> HistoricalBookingHolderHolder::
//   getListOfToBeUnconstrainedFlags () const {
//     std::vector<bool> lResult;
//     const short lSize = _historicalBookingHolderHolder.size();

//     for (short ite = 0; ite < lSize; ++ite) {
//       const HistoricalBooking lHistorialBooking =
//         _historicalBookingHolderHolder.at(ite);
//       const bool lFlag = lHistorialBooking.getFlag ();
//       if (lFlag == true) {
//         lResult.push_back(true);
//       }
//       else {
//         lResult.push_back(false);
//       }
//     }

//     return lResult;
//   }

  // //////////////////////////////////////////////////////////////////
//   HistoricalBookingHolder& HistoricalBookingHolderHolder::
//   getHistoricalBookingVector (const int i) const {
//     const HistoricalBookingHolder lHistoricalBookingVector =
//       _historicalBookingHolderHolder.at(i);
//     return lHistoricalBookingVector;
//   }

//   // //////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::
//   getUnconstrainedDemand (const short i) const {
//     const HistoricalBooking lHistorialBooking =
//       _historicalBookingHolderHolder.at(i);
//     double lResult = lHistorialBooking.getUnconstrainedDemand();
//     return lResult;
//   }

//   // //////////////////////////////////////////////////////////////////
//   void HistoricalBookingHolderHolder::setUnconstrainedDemand
//   (const double iExpectedDemand, const short i) {
//     _historicalBookingHolderHolder.at(i).setUnconstrainedDemand(iExpectedDemand);
//   }

//   // //////////////////////////////////////////////////////////////////////
//   const double HistoricalBookingHolderHolder::calculateExpectedDemand
//   (const double iMean, const double iSD,
//    const short i, const double iDemand) const {

//     const HistoricalBooking lHistorialBooking =
//       _historicalBookingHolderHolder.at(i);
//     const double lBooking = static_cast <double>
//       (lHistorialBooking.getNumberOfBookings());
//     double e, d1, d2;
//     /*
//       e = - (lBooking - iMean) * (lBooking - iMean) * 0.625 / (iSD * iSD);
//       e = exp (e);

//       // Prevent e to be too close to 0: that can cause d1 = 0.
//       //if (e < 0.01) {
//       //  return iDemand;
//       //}

//       double s = sqrt (1 - e);
      
//       if (lBooking >= iMean) {
//       d1 = 0.5 * (1 - s);
//       }
//       else {
//       d1 = 0.5 * (1 + s);
//       }
//     */
      
//     d1 = gsl_cdf_gaussian_Q (lBooking - iMean, iSD);
      
//     e = - (lBooking - iMean) * (lBooking - iMean) * 0.5 / (iSD * iSD);
//     e = exp (e);

//     d2 = e * iSD / sqrt(2 * 3.14159265);
      
//     // std::cout << "d1, d2 = " << d1 << "     " << d2 << std::endl;

//     if (d1 == 0) {
//       return iDemand;
//     }
      
//     const double lDemand =
//       static_cast<double> (iMean + d2/d1);
      
//     return lDemand;
//   }

//   // //////////////////////////////////////////////////////////////////
//   void HistoricalBookingHolderHolder::addHistoricalBooking
//   (const HistoricalBooking iHistoricalBooking) {
//     _historicalBookingHolderHolder.push_back(iHistoricalBooking);
//   }

//   // //////////////////////////////////////////////////////////////////
//   void HistoricalBookingHolderHolder::toStream (std::ostream& ioOut) const {
//     const short lSize = _historicalBookingHolderHolder.size();

//     ioOut << "Historical Booking; Unconstrained Demand; Flag" << std::endl;

//     for (short ite = 0; ite < lSize; ++ite) {
//       const HistoricalBooking lHistorialBooking =
//         _historicalBookingHolderHolder.at(ite);
        
//       const double lBooking =
//         lHistorialBooking.getNumberOfBookings();
        
//       const double lDemand =
//         lHistorialBooking.getUnconstrainedDemand();
        
//       const bool lFlag = lHistorialBooking.getFlag();

//       ioOut << lBooking << "    "
//             << lDemand << "    "
//             << lFlag << std::endl;
//     }
//   }

//   // //////////////////////////////////////////////////////////////////////
//   const std::string HistoricalBookingHolderHolder::describe() const {
//     std::ostringstream ostr;
//     ostr << "Holder of HistoricalBooking structs.";
     
//     return ostr.str();
//   }
    
//   // //////////////////////////////////////////////////////////////////
//   void HistoricalBookingHolderHolder::display() const {
//     toStream (std::cout);
//   }
    
}
