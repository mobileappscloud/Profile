import Foundation

class CompetitiveChallengeView: UIView, UIScrollViewDelegate {
    
    @IBOutlet var firstPositionAvatar: UIImageView!
    @IBOutlet var secondPositionAvatar: UIImageView!
    @IBOutlet var thirdPositionAvatar: UIImageView!
    @IBOutlet var firstPositionRank: UILabel!
    @IBOutlet var secondPositionRank: UILabel!
    @IBOutlet var thirdPositionRank: UILabel!
    @IBOutlet var firstPositionName: UILabel!
    @IBOutlet var secondPositionName: UILabel!
    @IBOutlet var thirdPositionName: UILabel!
    @IBOutlet var firstPositionProgressBar: UIView!
    @IBOutlet var secondPositionProgressBar: UIView!
    @IBOutlet var thirdPositionProgressBar: UIView!
    @IBOutlet var firstPositionPoints: UILabel!
    @IBOutlet var secondPositionPoints: UILabel!
    @IBOutlet var thirdPositionPoints: UILabel!
    
    //index of views in various 'row' arrays to associate data with views
    struct ViewConstants {
        static let nameIndex = 0;
        static let pointsIndex = 1;
        static let rankIndex = 2;
        static let avatarIndex = 3;
        
        static let barHeight:CGFloat = 5;
        static let barCornerRadius:CGFloat = 2;
    }
    
    class func instanceFromNib(challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView;
        
        let firstRow:[UILabel] = [competitiveView.firstPositionName, competitiveView.firstPositionPoints, competitiveView.firstPositionRank];
        let secondRow:[UILabel] = [competitiveView.secondPositionName, competitiveView.secondPositionPoints, competitiveView.secondPositionRank];
        let thirdRow:[UILabel] = [competitiveView.thirdPositionName, competitiveView.thirdPositionPoints, competitiveView.thirdPositionRank];
        let avatars:[UIImageView] = [competitiveView.firstPositionAvatar, competitiveView.secondPositionAvatar, competitiveView.thirdPositionAvatar];
        let progressBars:[UIView] = [competitiveView.firstPositionProgressBar, competitiveView.secondPositionProgressBar, competitiveView.thirdPositionProgressBar];
        
        let rows:[[UILabel]] = [firstRow, secondRow, thirdRow];
        
        let isTeamChallenge = winConditions[0].winnerType == "team";
        
        if (isTeamChallenge) {
            let gravityTuple = getTeamGravityBoard(challenge);
            let teamGravityBoard = gravityTuple.0;
            let teamRanks = gravityTuple.1;
            
            let highScore = challenge.teamHighScore;
            for index in 0...teamGravityBoard.count - 1 {
                let name = teamGravityBoard[index].name;
                let points = "\(Int(teamGravityBoard[index].units)) pts";
                let rank = Utility.getRankSuffix(String(teamRanks[index]));
                let avatarUrl = teamGravityBoard[index].imageUrl;
                populateLeaderBoardRow(rows[index], name: name, points: points, rank: rank);
                setAvatar(avatars[index], url: avatarUrl);
                if (name == challenge.participant.team.name) {
                    setTextGreen(rows[index]);
                }
                let progressBar = progressBars[index];
                setProgressBar(progressBar, points: Int(teamGravityBoard[index].units), highScore: Int(highScore));
            }
        } else {
            let individualGravityBoard = challenge.gravityBoard;
            
            let highScore = challenge.individualHighScore;
            for index in 0...individualGravityBoard.count - 1 {
                let name = individualGravityBoard[index].participant.displayName;
                let points = "\(Int(individualGravityBoard[index].participant.units)) pts";
                let rank = Utility.getRankSuffix(individualGravityBoard[index].place);
                let avatarUrl = individualGravityBoard[index].participant.imageUrl;
                populateLeaderBoardRow(rows[index], name: name, points: points, rank: rank);
                setAvatar(avatars[index], url: avatarUrl);
                if (name == challenge.participant.displayName) {
                    setTextGreen(rows[index]);
                }
                let progressBar = progressBars[index];
                setProgressBar(progressBar, points: Int(individualGravityBoard[index].participant.units), highScore: Int(highScore));
            }
        }
        return competitiveView;
    }
    
    class func populateLeaderBoardRow(row: [UILabel], name: String, points: String, rank: String) {
        row[ViewConstants.nameIndex].text = name;
        row[ViewConstants.pointsIndex].text = points;
        row[ViewConstants.rankIndex].text = rank;
    }
    
    class func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let newWidth = (CGFloat(points)/CGFloat(highScore)) * width;
        view.frame.size.width = (CGFloat(points)/CGFloat(highScore)) * width;

        let bar = UIView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y - ViewConstants.barHeight, width: newWidth, height: ViewConstants.barHeight));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = ViewConstants.barCornerRadius;
        view.addSubview(bar);
    }
    
    class func setTextGreen(row: [UILabel]) {
        row[ViewConstants.nameIndex].textColor = Utility.colorFromHexString("#76C044");
        row[ViewConstants.pointsIndex].textColor = Utility.colorFromHexString("#76C044");
    }
    
    class func setAvatar(view: UIImageView, url: String) {
        view.setImageWithURL(Utility.loadImageFromUrl(url));
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