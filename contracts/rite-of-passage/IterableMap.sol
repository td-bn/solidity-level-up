// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

library IterableMap {
    struct Map{
        address[] keys;
        mapping(address => bool) inserted;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
    }
    
    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }
    
    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }
    
    function getKeyAtIndex(Map storage map, uint index) external view returns(address) {
        return map.keys[index];
    }
    
    function size(Map storage map) external view returns(uint) {
        return map.keys.length;
    }
}


contract IterableMapTest {
    using IterableMap for IterableMap.Map;
    
    IterableMap.Map private map;
    
    function test() public {
        map.set(address(0), 0);
        map.set(address(1), 10);
        map.set(address(2), 20);
        
        address k;
        for (uint i=0; i<map.size(); i++) {
            k = map.getKeyAtIndex(i);
            assert(map.get(k) == i * 10);
        }
    }
}
