pipeline {
    agent {
        label 'ios'
    }

   /* options {
        // Accept Xcode license automatically
        xcodeLicense {
            acceptAutomatically()
        }
    }*/

    stages {
      /*  stage('Prepare') {
        }*/

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh "swift test --enable-code-coverage"
            }
        }

        stage('Coverage') {
            steps {
                sh "xcrun llvm-cov export -format='html' -instr-profile=\$(find .build -name default.profdata) \$(find .build -name LogPackageTests) > coverage.html"
            }
            post {
                success {
					sendSuccessMessageToMatterMost()
				}
				
				failure {
					sendErrorMessageToMatterMost()
				}

                always {
		            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'html', reportFiles: 'coverage.html', reportName: 'Coverage Report'])
					
					
/*                    publishCoverage adapters: [lcov(codeCoverage: [path: 'info.lcov'])]*/
					cleanWs()
                }				
            }
        }

       /* stage('Notify') {
            steps {
                withMattermost(
                    credentialsId: 'mattermost-credentials',
                    serverUrl: 'https://mattermost.example.com'
                ) {
                    mattermostSend color: 'good', message: "SPM package tests and coverage succeeded."
                }
            }
        }*/
    }
}

def sendSuccessMessageToMatterMost() {
	try {
	    mattermostSend channel: "#ios_jenkins", color: "good", message: "@channel Success - ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BUILD_URL})";
	} catch (ex) {
		echo "Error sending message to mattermost : ${ex}"
	}
}

def sendErrorMessageToMatterMost() {
	try {
	    mattermostSend channel: "#ios_jenkins", color: "danger", message: "@channel Pipeline failed - ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BUILD_URL})";
	} catch (ex) {
		echo "Error sending message to mattermost : ${ex}"
	}
}