// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// C
#include <assert.h>
// STL
#include <iostream>
#include <iomanip>
// RMOL
#include <rmol/bom/Bucket.hpp>
#include <rmol/bom/BucketHolder.hpp>

namespace RMOL {

  // //////////////////////////////////////////////////////////////////////
  BucketHolder::BucketHolder () :
    _cabinCapacity (100.0), _totalMeanDemand (0.0), _demandFactor (0.0),
    _optimalRevenue (0.0) {
  }

  // //////////////////////////////////////////////////////////////////////
  BucketHolder::BucketHolder (const double iCabinCapacity) :
    _cabinCapacity (iCabinCapacity), _totalMeanDemand (0.0), 
    _demandFactor (0.0), _optimalRevenue (0.0) {
  }

  // //////////////////////////////////////////////////////////////////////
  BucketHolder::~BucketHolder() {
    _bucketList.clear ();
  }

  // //////////////////////////////////////////////////////////////////////
  const short BucketHolder::getSize () const {
    return _bucketList.size();
  }

  // //////////////////////////////////////////////////////////////////////
  const std::string BucketHolder::describeShortKey() const {
    std::ostringstream oStr;
    oStr << _cabinCapacity;
    return oStr.str();
  }
  
  // //////////////////////////////////////////////////////////////////////
  const std::string BucketHolder::describeKey() const {
    return describeShortKey();
  }

  // //////////////////////////////////////////////////////////////////////
  std::string BucketHolder::toString() const {
    std::ostringstream oStr;
    oStr << describeShortKey()
         << ", " << _totalMeanDemand
         << ", " << _demandFactor  
         << ", " << _optimalRevenue
         << std::endl;
    
    return oStr.str();
  }   

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::toStream (std::ostream& ioOut) const {
    ioOut << toString();
  }
  
  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::fromStream (std::istream& ioIn) {
  }
  
  // //////////////////////////////////////////////////////////////////////
  const std::string BucketHolder::shortDisplay() const {
    std::ostringstream oStr;
    oStr << describeKey();
    return oStr.str();
  }
  
  // //////////////////////////////////////////////////////////////////////
  const std::string BucketHolder::display() const {
    std::ostringstream oStr;
    oStr << shortDisplay();
    // Generate a CSV (Comma Separated Values) output
    oStr << "Class; Price; Mean; Std Dev; Protection; Cum. Protection; Cum. Bkg Limit; "
          << std::endl;

    BucketList_T::const_iterator itBucket = _bucketList.begin();
    for (short j=1; itBucket != _bucketList.end(); itBucket++, j++) {
      const Bucket* currentBucket_ptr = *itBucket;
      assert (currentBucket_ptr != NULL);
      
      oStr << j << "; " << currentBucket_ptr->display();
    }

    oStr << "Cabin Capacity = " << _cabinCapacity
         << "; Total Mean Demand = " << _totalMeanDemand
         << "; Demand Factor = " << _demandFactor
         << "; Optimal Revenue = " << _optimalRevenue 
         << std::endl;
    return oStr.str();
  }

  // //////////////////////////////////////////////////////////////////////
  Bucket& BucketHolder::getCurrentBucket () const {
    Bucket* resultBucket_ptr = *_itCurrentBucket;
    assert (resultBucket_ptr != NULL);
    
    return (*resultBucket_ptr);
  }

  // //////////////////////////////////////////////////////////////////////
  Bucket& BucketHolder::getNextBucket () const {
    Bucket* resultBucket_ptr = *_itNextBucket;
    assert (resultBucket_ptr != NULL);
    
    return (*resultBucket_ptr);
  }

  // //////////////////////////////////////////////////////////////////////
  Bucket& BucketHolder::getTaggedBucket () const {
    Bucket* resultBucket_ptr = *_itTaggedBucket;
    assert (resultBucket_ptr != NULL);
    
    return (*resultBucket_ptr);
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::begin () {
    _itCurrentBucket = _bucketList.begin();
    _itNextBucket = _bucketList.begin();
    if (_itNextBucket != _bucketList.end()) {
      _itNextBucket++;
    }
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::tag () {
      _itTaggedBucket = _itCurrentBucket;
  }

  // //////////////////////////////////////////////////////////////////////
  bool BucketHolder::hasNotReachedEnd () const {
    bool result = (_itCurrentBucket != _bucketList.end());
    return result;
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::iterate () {
    if (_itCurrentBucket != _bucketList.end()) {
      _itCurrentBucket++;
    }
    if (_itNextBucket != _bucketList.end()) {
      _itNextBucket++;
    }
  }

  // //////////////////////////////////////////////////////////////////////
  const double BucketHolder::getPreviousCumulatedProtection () const {
    // Get the cumulated protection of the previous bucket. If the
    // current bucket is the first one, the function returns 0.0
    if (_itCurrentBucket == _bucketList.begin()) {
      return 0.0;
    } else {
      BucketList_T::iterator itPreviousBucket = _itCurrentBucket;
      --itPreviousBucket;
      Bucket* lPreviousBucket_ptr = *itPreviousBucket;
      const double oPreviousCumulatedProtection =
        lPreviousBucket_ptr->getCumulatedProtection();
      return oPreviousCumulatedProtection;
    }
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::calculateMeanDemandAndOptimalRevenue () {
    _totalMeanDemand = 0.0;
    _optimalRevenue = 0.0;

    for (BucketList_T::const_iterator itBucket = _bucketList.begin();
         itBucket != _bucketList.end(); itBucket++) {
      const Bucket* currentBucket_ptr = *itBucket;
      assert (currentBucket_ptr != NULL);

      // Mean Demand
      const double currentMeanDemand = currentBucket_ptr->getMean();
      _totalMeanDemand += currentMeanDemand;

      // Optimal Revenue
      const double currentPrice = currentBucket_ptr->getAverageYield();
      const double currentProtection = currentBucket_ptr->getProtection();
      const double bucketOptimalRevenue = currentPrice * currentProtection;
      _optimalRevenue += bucketOptimalRevenue;
    }

    if (_cabinCapacity != 0.0) {
      _demandFactor = _totalMeanDemand / _cabinCapacity;
    }
  }
  
  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::calculateProtectionAndBookingLimits () {
    // Number of classes/buckets: n
    const short nbOfClasses = getSize();

    /** 
        Iterate on the classes/buckets, from 1 to n-1.
        Note that n-1 corresponds to the size of the parameter list,
        i.e., n corresponds to the number of classes/buckets.
    */
    begin();
    Bucket& firstBucket = getCurrentBucket();

    // Set the cumulated booking limit of Bucket(1) to be equal to the capacity
    firstBucket.setCumulatedBookingLimit (_cabinCapacity);

    /** Set the protection of Bucket(1) to be equal to the cumulated protection
        of that first Bucket. */
    firstBucket.setProtection (firstBucket.getCumulatedProtection());

    for (short j=1 ; j <= nbOfClasses - 1; j++, iterate()) {
      /** Retrieve Bucket(j) (current) and Bucket(j+1) (next). */
      Bucket& currentBucket = getCurrentBucket();
      Bucket& nextBucket = getNextBucket();

      /**
         Set the cumulated booking limit for Bucket(j+1)
         (j ranging from 1 to n-1).
      */
      const double yjm1 = currentBucket.getCumulatedProtection();
      nextBucket.setCumulatedBookingLimit (_cabinCapacity - yjm1);

      /** Set the protection of Bucket(1) to be equal to
          the cumulated protection of that first Bucket. */
      const double yj = nextBucket.getCumulatedProtection();
      nextBucket.setProtection (yj - yjm1);
    }
  }

  // //////////////////////////////////////////////////////////////////////
  const double BucketHolder::getLowestAverageYield () {
    double oLowestAvgYield = 0.0;

    const short nbOfBuckets = getSize();
    assert (nbOfBuckets != 0);

    begin();
    Bucket& lFirstBucket = getCurrentBucket();
    oLowestAvgYield = lFirstBucket.getAverageYield();

    for (short j = 1; j < nbOfBuckets; ++j, iterate()) {
      Bucket& lNextBucket = getNextBucket();
      double lNextBucketAvgYield = lNextBucket.getAverageYield();
      if (lNextBucketAvgYield < oLowestAvgYield){
        oLowestAvgYield = lNextBucketAvgYield;
      }
    }
    return oLowestAvgYield;
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::recalculate () {
    // Re-calculate the booking limits
    calculateProtectionAndBookingLimits();
    
    // Re-calculate the Optimal Revenue
    calculateMeanDemandAndOptimalRevenue();
  }

  // //////////////////////////////////////////////////////////////////////
  void BucketHolder::
  fillup (BookingLimitVector_T& ioBookingLimitVector) const {
    BucketList_T::const_iterator itBucket = _bucketList.begin();
    for (short j=1; itBucket != _bucketList.end(); itBucket++, j++) {
      const Bucket* currentBucket_ptr = *itBucket;
      assert (currentBucket_ptr != NULL);
      
      const double lCumulatedBookingLimit =
        currentBucket_ptr->getCumulatedBookingLimit();
      ioBookingLimitVector.push_back(lCumulatedBookingLimit);
    }

  }

}