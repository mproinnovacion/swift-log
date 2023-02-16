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
                sh "xcrun llvm-cov export -format="lcov" -instr-profile=$(find .build -name default.profdata) $(find .build -name LogPackageTests) > info.lcov"
            }
            post {
                always {
                    publishCoverage adapters: [lcov(codeCoverage: [path: 'info.lcov'])]
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