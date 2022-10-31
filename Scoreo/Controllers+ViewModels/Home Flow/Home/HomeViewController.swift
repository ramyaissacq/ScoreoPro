//
//  HomeViewController.swift
//  775775Sports
//
//  Created by Remya on 9/2/22.
//

import UIKit
import DropDown
import Lottie

enum SportsType{
    case soccer
    case basketball
}

class HomeViewController: BaseViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var collectionViewMatch:UICollectionView!
    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var leagueView: UIView!
    @IBOutlet weak var lblLeague: UILabel!
    @IBOutlet weak var highlightsStack: UIStackView!
    @IBOutlet weak var collectionViewHighlights: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionViewHighlightsHeight: NSLayoutConstraint!
    @IBOutlet weak var animationView: AnimationView!
    
    
    @IBOutlet weak var collectionViewTime: UICollectionView!
    
    //MARK: - Variables
    var viewModel = HomeVieModel()
    var page = 1
    var refreshControl:UIRefreshControl?
    var categorySizes = [CGFloat]()
    var selectedType = 0
    var selectedLeagueID:Int?
    var selectedTimeIndex = 0
    var selectedDate = ""
    var longPressId:Int?
    var current = 0
    var selectedSportsType = SportsType.soccer
    var timerPinsRefresh = Timer()
    var timerPinsAlert = Timer()
    var timerHighlightsRefresh = Timer()
    var isHighlights = false
    static var urlDetails:UrlDetails?
    var timeArray = ["Today".localized,"Result".localized,"Schedule".localized]
    var sportsView:SportsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()
    }
    
     
    
    override func viewDidAppear(_ animated: Bool) {
        collectionViewTime.selectItem(at: IndexPath(row: selectedTimeIndex, section: 0), animated: false, scrollPosition: .left)
    }
    
    //MARK: - IBActions
    @IBAction func actionTapSports(_ sender: Any) {
         let sportIndex = (selectedSportsType == .soccer) ? 0 : 1
        Dialog.openSportsDialog(selectedSport: sportIndex) { index in
            if index == 0{
                self.selectedSportsType = .soccer
            }
            else{
                self.selectedSportsType = .basketball
            }
            self.configureSportSelection()
        }
    }
    
    func initialSettings(){
        
        setupHilightsTimer()
        setupNavButtons()
        setupGestures()
        configureLottieAnimation()
        lblLeague.text = "All Leagues".localized
        viewModel.categories = viewModel.todayCategories
        collectionViewTime.registerCell(identifier: "SelectionCollectionViewCell")
        collectionViewCategory.registerCell(identifier: "RoundSelectionCollectionViewCell")
        collectionViewHighlights.registerCell(identifier: "HighlightsCollectionViewCell")
        collectionViewCategory.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        collectionViewMatch.registerCell(identifier: "MatchCollectionViewCell")
        collectionViewMatch.registerCell(identifier: "LoaderCollectionViewCell")
        collectionViewMatch.registerCell(identifier: "ScheduledMatchCollectionViewCell")
       
        
//        if AppPreferences.getMatchHighlights().isEmpty{
//            highlightsStack.isHidden = true
//        }
//        else{
//            pageControl.numberOfPages = AppPreferences.getMatchHighlights().count
//            highlightsStack.isHidden = false
//        }
        
        viewModel.delegate = self
        viewModel.getMatchesList(page: page)
        viewModel.getBasketballScores()
    }
    
    
    
    func configureLottieAnimation(){
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
        
    }
    
   
   
    
    func configureSportSelection(){
        resetSportType()
        if selectedSportsType == .soccer{
            if AppPreferences.getMatchHighlights().count > 0{
                collectionViewHighlightsHeight.constant = 180
                collectionViewHighlights.reloadData()
                highlightsStack.isHidden = false
                pageControl.numberOfPages = AppPreferences.getMatchHighlights().count
            }
            else{
                highlightsStack.isHidden = true
            }
        }
        else{
            if AppPreferences.getBasketBallHighlights().count > 0{
                collectionViewHighlightsHeight.constant = 263
                collectionViewHighlights.reloadData()
                highlightsStack.isHidden = false
                pageControl.numberOfPages = AppPreferences.getBasketBallHighlights().count
            }
            else{
                highlightsStack.isHidden = true
            }
            
        }
        
    }
    
    func openLeaguePopup(){
        if viewModel.scoreResponse?.todayHotLeague?.count == 0{
            return
        }
        var leagues = viewModel.scoreResponse?.todayHotLeague ?? []
        var fob = TodayHotLeague()
        fob.leagueName = "All Leagues".localized
        fob.leagueId = 0
        leagues.insert(fob, at: 0)
        let vc = UIStoryboard(name: "Dialogs", bundle: nil).instantiateViewController(identifier: "LeaguePopupViewController") as! LeaguePopupViewController
        vc.leagues = leagues
        vc.originalLeagues = leagues
        vc.callSelected = { obj in

            self.lblLeague.text = obj.leagueName
            if obj.leagueId == 0{
                self.selectedLeagueID = nil
                if self.selectedTimeIndex == 0 && self.selectedSportsType == .soccer{
                    self.page = 1
                    self.viewModel.getMatchesList(page: self.page)
                }
                
            }
            else{
                self.selectedLeagueID = obj.leagueId
                self.viewModel.getMatchesByLeague(leagueID: self.selectedLeagueID!)
            }
        }
        self.present(vc, animated: true, completion: nil)
       
        
    }
    
    func resetSportType(){
        viewModel.categories = viewModel.todayCategories
        collectionViewCategory.reloadData()
        selectedTimeIndex = 0
        collectionViewTime.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        if selectedSportsType == .soccer{
            lblLeague.text = "All Leagues".localized
            page = 1
            viewModel.getMatchesList(page: page)
        }
        else{
            viewModel.getBasketballScores()
        }
        categorySizes.removeAll()
        collectionViewCategory.reloadData()
        collectionViewCategory.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    
    func handleTimeSelection(index:Int){
        
        selectedTimeIndex = index
        switch index{
        case 0:
            viewModel.categories = viewModel.todayCategories
            collectionViewCategory.reloadData()
            if selectedSportsType == .soccer{
                
                page = 1
                viewModel.getMatchesList(page: page)
            }
            else{
                viewModel.getBasketballScores()
            }
        case 1:
            viewModel.categories = viewModel.pastDates
            lblLeague.text = "All Leagues".localized
        case 2:
            viewModel.categories = viewModel.futureDates
            lblLeague.text = "All Leagues".localized
            
        default:
            break
        }
        categorySizes.removeAll()
        collectionViewCategory.reloadData()
        collectionViewCategory.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        collectionViewCategory.delegate?.collectionView?(collectionViewCategory, didSelectItemAt: IndexPath(row: 0, section: 0))
        
    }
    
    func setupGestures(){
        let tapLg = UITapGestureRecognizer(target: self, action: #selector(tapLeague))
        leagueView.addGestureRecognizer(tapLg)
       
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipe(sender:)))
        left.direction = .left
        left.delegate = self
        collectionViewHighlights.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipe(sender:)))
        right.direction = .right
        right.delegate = self
        collectionViewHighlights.addGestureRecognizer(right)
        
    }
    
    
    @objc func tapLeague(){
        let mapCnt = HomeViewController.urlDetails?.map?.count ?? 0
        if mapCnt > 0{
            if selectedSportsType == .soccer && selectedTimeIndex == 0{
            openLeaguePopup()
        }
        }
        
    }
    
   
    
    @objc func swipe(sender:UISwipeGestureRecognizer){
        if sender.direction == .left{
            var total = AppPreferences.getMatchHighlights().count
            if self.selectedSportsType == .basketball{
                total = AppPreferences.getBasketBallHighlights().count
            }
            if current < (total - 1){
                current += 1
                collectionViewHighlights.scrollToItem(at: IndexPath(row: current, section: 0), at: .centeredHorizontally, animated: true)
                pageControl.currentPage = current
            }
        }
        else{
            if current > 0{
                current -= 1
                collectionViewHighlights.scrollToItem(at: IndexPath(row: current, section: 0), at: .centeredHorizontally, animated: true)
                pageControl.currentPage = current
                
            }
        }
        
    }
    
    
    
    @objc func refresh(){
        if selectedTimeIndex == 0 && selectedLeagueID == nil{
            page = 1
            viewModel.getMatchesList(page: page)
        }
        refreshControl?.endRefreshing()
    }
    
    func setupNavButtons(){
        let lbl = getHeaderLabel(title: "Football".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lbl)
        let rightBtn = getButton(image: UIImage(named: "search")!)
        rightBtn.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBtn)]
    }
    
    @objc func menuTapped(){
        BaseViewController.openSideMenu(vc: self)
        //openVC(storyBoard: "SideMenu", identifier: "SideMenuViewController")
    }
    
    @objc func searchTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.viewModel.originals = viewModel.originals
        vc.viewModel.pageData = viewModel.pageData
        vc.page = page
        vc.viewModel.originaBasketballMatches = viewModel.originaBasketballMatches
        vc.selectedSport = self.selectedSportsType
        vc.selectedTimeIndex = selectedTimeIndex
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func setupHilightsTimer(){
        if !(AppPreferences.getMatchHighlights().isEmpty) || !(AppPreferences.getBasketBallHighlights().isEmpty){
            timerHighlightsRefresh = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(refreshHilights), userInfo: nil, repeats: true)
        }
    }
    
    @objc func refreshHilights(){
        for m in AppPreferences.getMatchHighlights(){
            print("football id: \(m.matchId ?? 0)")
            viewModel.getMatchDetails(id: m.matchId ?? 0)
        }
        
        for m in AppPreferences.getBasketBallHighlights(){
            print("basketball id: \(m.matchId ?? 0)")
            viewModel.getBasketballMatchDetails(id: m.matchId ?? 0)
        }
        
    }
    
    
    static func showPopup(){
        let frequency = AppPreferences.getPopupFrequency()
        let promptFrequency = Int(HomeViewController.urlDetails?.promptFrequency ?? "") ?? 0
        if frequency < promptFrequency{
            let title = HomeViewController.urlDetails?.promptTitle ?? ""
            let message = HomeViewController.urlDetails?.promptMessage ?? ""
            if title.count > 0{
                Dialog.openSuccessDialog(buttonLabel: "OK".localized, title: title, msg: message, completed: {})
                AppPreferences.setPopupFrequency(frequency: frequency+1)
            }
        }
    }
    
    //    func setupTimerForpinRefresh(){
    //        if !AppPreferences.getPinList().isEmpty{
    //            timerPinsRefresh = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(refreshPins), userInfo: nil, repeats: true)
    //
    //        }
    //    }
    //
    //    @objc func refreshPins(){
    //        let pins = AppPreferences.getPinList()
    //        for m in pins{
    //            viewModel.getMatchDetails(id: m.matchId ?? 0)
    //
    //        }
    //
    //    }
    //
    //    func setupTimerForPinAlert(){
    //        if !AppPreferences.getPinList().isEmpty{
    //            timerPinsAlert = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(showAlert), userInfo: nil, repeats: true)
    //        }
    //    }
    //
    //    @objc func showAlert(){
    //        let pins = AppPreferences.getPinList()
    //        if let obj = pins.filter({!($0.state == 0 || $0.state == -1)}).first{
    //            Utility.scheduleLocalNotificationNow(time: 1, title: "\(obj.homeName ?? "") Vs \(obj.awayName ?? "")", subTitle: "", body: "Scores - \(obj.homeScore ?? 0):\(obj.awayScore ?? 0), C - \(obj.homeCorner ?? ""):\(obj.awayCorner ?? ""), HT - \(obj.homeHalfScore ?? ""):\(obj.awayHalfScore ?? "")", data: ["id" : obj.matchId ?? 0], repeats: false)
    //
    //        }
    //    }
    
    
}


