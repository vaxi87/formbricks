import SwiftUI

struct FormbricksView: View {
    @ObservedObject var viewModel: FormbricksViewModel
    
    var body: some View {
        if let htmlString = viewModel.htmlString, let surveyId = viewModel.surveyId {
            SurveyWebView(surveyId: surveyId, htmlString: htmlString)
        }
    }
}
