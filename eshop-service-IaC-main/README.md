# Service EKS Cluster 생성용 IaC Repository

ⓘ 목적 : Service EKS Cluster Provisioning 하기위해 IaC를 도입 및 운영에 활용한다.

## IaC Terraform 수행
 - IaC Code 수행내역    
   Service VPC 및 Subnet, Route Table, Nat/Internet Gateway, EIP 생성 및 설정    
   Service EKS Cluster / Service EKS Cluster Node Group 생성 및 설정    
      
<br>

### 1. AWS Region 및 MGMT VPC의 Nat Gateway IP를 설정한다.

- us-west-2(Oregon) 리젼에서 진행
- terraform.tfvars
- `<< MGMT VPC NAT Gateway IP >>` 변수는 실제 MGMT VPC의 Nat Gateway IP로 치환하여 입력해준다.

```bash
aws_region = "us-west-2" # service VPC가 생성될 region 설정
mgmt_nat_gw_ip  = "<< MGMT VPC NAT Gateway IP >>"
```
> << MGMT VPC NAT Gateway IP >> 값은 반드시 실제 값으로 치환한다.


### 2. Terraform Backend(S3) 설정한다. (예시이므로 반드시 본인 정보로 설정)

- S3 버킷은 us-east-1(N.Virginia) 리젼에서 생성
- provider.tf내 bucket명 수정
- provider.tf 5번째 라인 삭제

```bash
terraform {
  backend "s3" {
    bucket = "<<개인 버킷>>"           # 개인이 생성한 S3 버킷의 실제 이름 ex) bucket = t3msp
    key    = "service/terraform.tfstate" # service 인프라의 tfstate 파일 저장 path(고정값)
    3번째 라인의 <<개인 버킷>> 변수를 개인이 생성한 실제 버킷명으로 치환 후 현재 5번째 라인도 같이 삭제합니다. ex) bucket = "t3msp" -- (provider.tf 3번째 라인 bucket값 치환 && 현재 5번째 라인 전체 삭제)
    region = "us-east-1"              # S3가 존재하는 region
    skip_s3_checksum=true             # Terraform 1.6 이상부터 추가 파라메터
    skip_requesting_account_id=true   # Terraform 1.6 이상부터 추가 파라메터
  }
  required_version = ">=1.1.3"
}

provider "aws" {
  region = var.aws_region
}
```

<br>

### 3. 사전 Github Credential 및 Jenkins awsCredentials 세팅 필요


#### Github Credential 설정

Jenkins 관리 > Credentials 메뉴를 선택한다.

<br>

Domains (global)을 선택한다.

<br>

화면 우측 상단의 `+ Add Credentials` 버튼을 누르고 다음과 같이 입력한다. Password에는 앞서 만든 `Github의 Personal Access Token` 값을 입력한다.

<br>

|항목|내용|액션|
|---|---|---|
|➕ Kind  | `Username with password`|셀렉트박스 선택|
|➕ Username | `<< GITHUB USER NAME >>`|입력|
|➕ Password |`<< GITHUB TOKEN >>`|입력|
|➕ ID |`github`|입력|
|➕ Description |`for github login`|입력|
> 참고. << GITHUB TOKEN >> : 1일차 Github 세팅 중 생성한 Github Developer Token(60일 유효) 값을 의미한다. 기록해둔 해당 값으로 치환을 한다.

<br>

#### Jenkins awsCredentials 설정

- 반드시 ID값을 'awsCredentials'로 추가
- `Add Credentials` 클릭 후 AWS credentials 생성한다.
- jenkins pipeline 에서 terraform 을 이용해 eshop용 인프라 생성을 한다. 이를 위해 AWS IAM 사용자의 access key를 등록

> |항목|내용|액션|
> |---|---|---|
> |➕ Kind | `AWS Credentials` | 선택|
> |➕ ID |  `awsCredentials` | 입력|
> |➕ Access Key ID |  << AWS Access Key ID >> | 📌 메모값 입력|
> |➕ Secret Access Key  | << AWS Secret Access key >> | 📌 메모값 입력|

<br>
<br>