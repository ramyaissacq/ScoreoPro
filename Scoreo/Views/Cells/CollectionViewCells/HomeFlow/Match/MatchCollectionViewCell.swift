//
//  MatchCollectionViewCell.swift
//  Scoreo
//
//  Created by Remya on 10/26/22.
//

import UIKit

class MatchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var oddsBackView: UIView!
    
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblHomeName: UILabel!
    
    @IBOutlet weak var lblAwayName: UILabel!
    
    @IBOutlet weak var lblHomeScore: UILabel!
    @IBOutlet weak var lblAwayScore: UILabel!
    
    @IBOutlet weak var lblHomeYellow: UILabel!
    @IBOutlet weak var lblAwayYellow: UILabel!
    @IBOutlet weak var lblHomeRed: UILabel!
    @IBOutlet weak var lblAwayRed: UILabel!
    @IBOutlet weak var imgHomeLogo: UIImageView!
    @IBOutlet weak var imgAwayLogo: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblHalfTime: UILabel!
    @IBOutlet weak var lblCorner: UILabel!
    @IBOutlet weak var lblHandicap1: UILabel!
    @IBOutlet weak var lblHandicap2: UILabel!
    @IBOutlet weak var lblHandicap3: UILabel!
    @IBOutlet weak var lblOverUnder1: UILabel!
    @IBOutlet weak var lblOverUnder2: UILabel!
    @IBOutlet weak var lblOverUnder3: UILabel!
   
    @IBOutlet weak var odds2Stack: UIStackView!
    @IBOutlet weak var odds1Stack: UIStackView!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(obj:MatchList?){
       
        lblName.text = obj?.leagueName
        lblHomeName.text = obj?.homeName
        lblAwayName.text = obj?.awayName
        lblHomeScore.text = "\(obj?.homeScore ?? 0 )"
        lblAwayScore.text = "\(obj?.awayScore ?? 0)"
        lblHomeYellow.text = "\(obj?.homeYellow ?? 0)"
        lblAwayYellow.text = "\(obj?.awayYellow ?? 0)"
        lblHomeRed.text = "\(obj?.homeRed ?? 0)"
        lblAwayRed.text = "\(obj?.awayRed ?? 0)"
        let mins = ScoresTableViewCell.timeInMins(startDate: obj?.startTime ?? "")
        if obj?.state == -1{
            lblTime.text = ScoresTableViewCell.getStatus(state: obj?.state ?? 0)
        }
        else{
        lblTime.text = "\(ScoresTableViewCell.getStatus(state: obj?.state ?? 0)) \(mins)'"
        }
        if obj?.state == 0{
            let matchDate = Utility.getSystemTimeZoneTime(dateString: obj?.matchTime ?? "")
            lblTime.text = Utility.formatDate(date: matchDate, with: .hhmm2)
        }

        
        var halfScore = ""
        var corner = ""
        if obj?.homeHalfScore == "0" && obj?.awayHalfScore == "0"{
            halfScore = ""
        }
        else{
            halfScore = "HT = \(obj?.homeHalfScore ?? "") : \(obj?.awayHalfScore ?? "")"
        }
        if obj?.homeCorner == "0" && obj?.awayCorner == "0"{
            corner = ""
        }
        else{
        corner = "C = \(obj?.homeCorner ?? "") : \(obj?.awayCorner ?? "")"
        }
        lblCorner.text = corner
        lblHalfTime.text = halfScore
        
        if obj?.odds?.handicap?.count ?? 0 > 7{
        lblHandicap1.text = String(obj?.odds?.handicap?[6] ?? 0)
        lblHandicap2.text = String(obj?.odds?.handicap?[5] ?? 0)
        lblHandicap3.text = String(obj?.odds?.handicap?[7] ?? 0)
            odds1Stack.isHidden = false
        }
        else{
            odds1Stack.isHidden = true
        }
        if obj?.odds?.overUnder?.count ?? 0 > 7{
        lblOverUnder1.text = String(obj?.odds?.overUnder?[6] ?? 0)
        lblOverUnder2.text = String(obj?.odds?.overUnder?[5] ?? 0)
        lblOverUnder3.text = String(obj?.odds?.overUnder?[7] ?? 0)
            odds2Stack.isHidden = false
        }
        else{
            odds2Stack.isHidden = true
        }
        
        if (obj?.odds?.overUnder?.isEmpty ?? true) && (obj?.odds?.handicap?.isEmpty ?? true){
            oddsBackView.isHidden = true
        }
        else{
            oddsBackView.isHidden = false
        }
      
      
    }

}
