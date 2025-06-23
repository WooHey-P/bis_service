# 프로젝트 개요

버스 도착 정보를 시뮬레이션 형태로 제공하는 BIS(Bus Information System) 웹 애플리케이션을 개발한다.  
초기 버전은 **로컬에서 생성한 fake data**를 기반으로 하며, **실제 공공 데이터 API는 사용하지 않는다**.

사용자는 웹 브라우저에서 정류장을 검색하고, 해당 정류장의 도착 예정 버스 목록과 노선을 확인할 수 있다.  
지도는 API 키 없이 사용 가능한 **OpenStreetMap** 기반 플랫폼을 활용한다.

# 주요 사용자 시나리오

- 사용자는 웹 브라우저에서 접속한다 (Flutter Web 기반).
- 정류장을 검색하거나 위치 기반으로 근처 정류장을 탐색한다.
- 선택한 정류장에 도착 예정인 버스 목록을 확인한다.
- 버스 번호를 클릭하면 해당 버스의 전체 경로와 현재 위치(시뮬레이션된 위치)를 확인할 수 있다.
- 자주 사용하는 정류장을 즐겨찾기에 등록할 수 있다.

# 핵심 기능

## 1. 정류장 검색
- 정류장 이름 또는 ID로 검색
- 자동완성 기능 제공

## 2. 정류장 상세 정보
- 해당 정류장의 버스 목록 표시
- 각 버스의 도착 예정 시간, 남은 정류장 수 (fake data 기반)

## 3. 버스 노선 보기
- 버스 번호 클릭 시 전체 경로 표시
- 현재 버스의 위치는 시뮬레이션된 방식으로 갱신됨 (주기적 위치 이동)

## 4. 위치 기반 정류장 탐색
- 사용자의 위치를 기반으로 근처 정류장 표시 (fake 좌표 기반 탐색)

## 5. 즐겨찾기 기능
- 정류장 즐겨찾기 추가/삭제
- Flutter local storage (shared_preferences 또는 Hive 등) 활용

# 데이터 시뮬레이션

- `bus_routes.json`, `bus_stations.json`, `bus_status.json` 등의 정적 JSON 파일 사용
- 버스 위치는 5초 간격으로 자동 갱신 (Flutter timer 또는 stream 활용)
- 시간 경과에 따른 버스 위치 계산 로직 포함

# 기술 스택

## 프론트엔드

- **Flutter Web**
  - Riverpod (상태관리)
  - Flutter Map + OpenStreetMap (지도 렌더링)
  - dio/http 패키지를 통해 Node.js 서버와 통신
  - shared_preferences 또는 Hive로 즐겨찾기 저장

## 백엔드

- **Node.js + Express**
  - 정적 JSON 데이터 파일 제공
  - `/stations`, `/routes`, `/status` 등의 REST API 제공
  - 정적 파일 서버 또는 간단한 로직으로 fake 데이터 주기적 갱신

## 기타

- **지도 플랫폼**: OpenStreetMap (API 키 필요 없음)
- **DB**: 사용하지 않음 (초기에는 JSON 기반만 사용)
- **배포**: 프론트는 Firebase Hosting 또는 Vercel, 백엔드는 Render 또는 Railway

# API 예시

```http
GET /stations
GET /stations/:id
GET /routes/:id
GET /status/:busId
