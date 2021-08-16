// SPDX-License-Identifier: MIT 

pragma solidity >=0.8.0;

contract Club {
    function speak() virtual public returns (string memory) {
        return "I am a club.";
    }
}

contract FootballClub is Club{
    function speak() virtual override public returns(string memory) {
        return "I am a footbal club.";
    }
}

contract ChampionsLeagueClub is FootballClub {
    function speak() virtual override public returns(string memory) {
        // return super.speak();
        return "I am a Champions League Club.";
    }
}

contract PremierLeagueClub is FootballClub {
    function speak() virtual override public returns(string memory) {
        return super.speak();
        // return "I am a Premier League Club";
    }
}


contract Liverpool is ChampionsLeagueClub, PremierLeagueClub {
    function speak() override(ChampionsLeagueClub, PremierLeagueClub) public returns(string memory) {
        return super.speak();
    }
}
