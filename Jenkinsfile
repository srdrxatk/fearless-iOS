@Library('jenkins-library') _

// Job properties
def jobParams = [
  booleanParam(defaultValue: false, description: 'push to the dev profile', name: 'prDeployment'),
]

def appPipline = new org.ios.AppPipeline(
    steps: this, 
    appTests: true,
    appPushNoti: true,
    jobParams: jobParams,
    label: 'macos-ios-1-2')
appPipline.runPipeline('fearless')
