def call(String buildStatus = 'STARTED') {
    // Build status of null means success.
    buildStatus = buildStatus ?: 'SUCCESS'

    def colorCode = '#FF0000'
    if (buildStatus == 'SUCCESS') {
        colorCode = '#36A64F'
    } else if (buildStatus == 'UNSTABLE') {
        colorCode = '#FFFF00'
    }

    // Slack message ...
    def message = "*${buildStatus}:* Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"

    slackSend(color: colorCode, message: message, channel: "#${env.SLACK_CHANNEL}")
}
