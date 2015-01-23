import Foundation

class CompetitiveChallengeView: UIView, UIScrollViewDelegate {
    
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    
    class func instanceFromNib(challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView;
        
        var rows = [competitiveView.row1, competitiveView.row2, competitiveView.row3];
        let isTeamChallenge = winConditions[0].winnerType == "team";
        
        if (isTeamChallenge) {
            let gravityTuple = getTeamGravityBoard(challenge);
            let teamGravityBoard = gravityTuple.0;
            let teamRanks = gravityTuple.1;
            
            let highScore = challenge.teamHighScore;
            for index in 0...teamGravityBoard.count - 1 {
                let name = teamGravityBoard[index].name;
                let row = ChallengeLeaderboardRow.instanceFromNib(challenge, team: teamGravityBoard[index], index: index);
                if (name == challenge.participant.team.name) {
                    row.name.textColor = Utility.colorFromHexString("#76C044");
                    row.place.textColor = Utility.colorFromHexString("#76C044");
                }
                rows[index].addSubview(row);
            }
        } else {
            let individualGravityBoard = challenge.gravityBoard;
            
            let highScore = challenge.individualHighScore;
            for index in 0...individualGravityBoard.count - 1 {
                let name = individualGravityBoard[index].participant.displayName;
                let row = ChallengeLeaderboardRow.instanceFromNib(challenge, participant: individualGravityBoard[index].participant, index: index);
                if (name == challenge.participant.displayName) {
                    row.name.textColor = Utility.colorFromHexString("#76C044");
                    row.place.textColor = Utility.colorFromHexString("#76C044");
                }
                rows[index].addSubview(row);
            }
        }
        return competitiveView;
    }
    
    //ouput team gravity board from full teams array
    class func getTeamGravityBoard(challenge: HigiChallenge) -> ([ChallengeTeam], [Int]){
        let teams = challenge.teams;
        if (teams != nil) {
            var userTeamIndex = getUserIndex(teams, userTeam: challenge.participant.team);
            if (userTeamIndex != -1) {
                //calculate offsets, e.g. grab 1,2,3 or 4,5,6 from gravity board
                var startIndex:Int, endIndex:Int;
                //user's team in first
                if (userTeamIndex == 0) {
                    startIndex = userTeamIndex;
                    endIndex = userTeamIndex + 2;
                }
                    //user's team in last
                else if (userTeamIndex == teams.count - 1) {
                    startIndex = userTeamIndex - 2;
                    endIndex = userTeamIndex;
                }
                    //somewhere in the middle
                else {
                    startIndex = userTeamIndex - 1;
                    endIndex = userTeamIndex + 1;
                }
                //account for cases where size < 3 or = 3 but user's team not second
                startIndex = max(startIndex, 0);
                endIndex = min(endIndex, teams.count - 1);
                
                var gravityBoard:[ChallengeTeam] = [];
                var ranks:[Int] = [];
                
                for index in startIndex...endIndex {
                    //index - startIndex is effectively a counter
                    gravityBoard.append(teams[index]);
                    ranks.append(index + 1);
                }
                return (gravityBoard, ranks);
            }
        }
        return ([],[]);
    }
    
    //helper to find the current team's index
    class func getUserIndex(teams: [ChallengeTeam], userTeam: ChallengeTeam) -> Int {
        for index in 0...teams.count-1 {
            let thisTeam = teams[index];
            if (thisTeam.name == userTeam.name) {
                userTeam.place = index;
                return index;
            }
        }
        return -1;
    }
}