// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// C
#include <assert.h>
// STL
#include <limits>
// RMOL Common
#include <rmol/service/Logger.hpp>
#include <rmol/bom/StatAggregatorStruct.hpp>
#include <rmol/bom/StudyStatManager.hpp>

namespace RMOL {

  // //////////////////////////////////////////////////////////////////////
  StudyStatManager::StudyStatManager () {
  }
  
  // //////////////////////////////////////////////////////////////////////
  StudyStatManager::~StudyStatManager () {
  }
  
  // //////////////////////////////////////////////////////////////////////
  const std::string StudyStatManager::describe() const {
    std::ostringstream ostr;
    
    for (StatAggregatorStructList_T::const_iterator itStatAggregatorStruct =
           _statAggregatorStructList.begin();
         itStatAggregatorStruct != _statAggregatorStructList.end();
         ++itStatAggregatorStruct) {
      const StatAggregatorStruct_T& lStatAggregatorStruct =
        itStatAggregatorStruct->second;
      
      ostr << lStatAggregatorStruct.describeCurrentSimu() << std::endl;
    }
    
    return ostr.str();
  }
  
  // //////////////////////////////////////////////////////////////////////
  void StudyStatManager::display() const {
    
    // Store current formatting flags of std::cout
    std::ios::fmtflags oldFlags = std::cout.flags();
    
    for (StatAggregatorStructList_T::const_iterator itStatAggregatorStruct =
           _statAggregatorStructList.begin();
         itStatAggregatorStruct != _statAggregatorStructList.end();
         ++itStatAggregatorStruct) {
      const StatAggregatorStruct_T& lStatAggregatorStruct =
        itStatAggregatorStruct->second;
      
      std::cout << lStatAggregatorStruct.describeCurrentSimu() << std::endl;
    }
    
    // Reset formatting flags of std::cout
    std::cout.flags (oldFlags);
  }

  // //////////////////////////////////////////////////////////////////////
  StatAggregatorStruct_T& StudyStatManager::
  getStatAggregator(const std::string& iStatAggregatorName) {
    StatAggregatorStructList_T::iterator itAggregatorStruct =
      _statAggregatorStructList.find (iStatAggregatorName);
    
    // If the StatAggregatorStruct does not exist, it is created
    if (itAggregatorStruct == _statAggregatorStructList.end()) {
      StatAggregatorStruct_T lStatAggregatorStruct (*this, iStatAggregatorName);
      _statAggregatorStructList.
        insert (StatAggregatorStructList_T::
                value_type (lStatAggregatorStruct.describeKey(),
                            lStatAggregatorStruct));
      itAggregatorStruct =
        _statAggregatorStructList.find (iStatAggregatorName);        
    }
    
    return itAggregatorStruct->second;
  }
  
  // //////////////////////////////////////////////////////////////////////
  void StudyStatManager::addMeasure (const std::string iStatAggregatorName,
                                     const double iMeasureValue) {
    // retrieve the corresponding statAggregator or create it
    StatAggregatorStruct_T& lStatAggregator =
      getStatAggregator(iStatAggregatorName);
    
    // add new measure
    lStatAggregator.addMeasure(iMeasureValue);
  }

  
  // //////////////////////////////////////////////////////////////////////
  const std::string StudyStatManager::describeShortKey() const {
    std::ostringstream oStr;
    return oStr.str();
  }
  
  // //////////////////////////////////////////////////////////////////////
  const std::string StudyStatManager::describeKey() const {
    return describeShortKey();
  }

  // //////////////////////////////////////////////////////////////////////
  std::string StudyStatManager::toString() const {
    std::ostringstream oStr;
    return oStr.str();
  }   

  // //////////////////////////////////////////////////////////////////////
  void StudyStatManager::toStream (std::ostream& ioOut) const {
    ioOut << toString();
  }
  
  // //////////////////////////////////////////////////////////////////////
  void StudyStatManager::fromStream (std::istream& ioIn) {
  }
  
  
}