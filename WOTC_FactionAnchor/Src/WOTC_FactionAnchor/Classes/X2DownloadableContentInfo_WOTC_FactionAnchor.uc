//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTC_FactionAnchor.uc                                    
//
//	CREATED BY RustyDios
//           
//	File created	02/02/21	23:45
//	LAST UPDATED    04/02/21    16:15
//
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTC_FactionAnchor extends X2DownloadableContentInfo;

var config bool bEnableFactionAnchorLog;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}
