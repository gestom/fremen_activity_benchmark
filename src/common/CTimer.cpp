#include "CTimer.h"

l = timeout;
  pause();
}


CTimer::~CTimer()
{}


void CTimer::reset(int timeout)
{
  timeoutInterval = timeout;
  startTime = getRealTime();
  pauseTime = startTime;
}

int CTimer::getRealTime()
{
  struct  timeval currentTime;
  gettimeofday(&currentTime, NULL);
  return currentTime.tv_sec*1000000 + currentTime.tv_usec;
}

int CTimer::getTime()
{
  int result;
  if (running)
  {
    result = getRealTime() - startTime;
  }
  else
  {
    result = pauseTime - startTime;
  }
  return result;
}

bool CTimer::timeOut()
{
  return getTime() > timeoutInterval;
}

int CTimer::getRest()
{
	int result = timeoutInterval-getTime();
	if (result < 0) result = 0;
	return result;
}

int CTimer::pause()
{
  running = false;
  return pauseTime = getRealTime();
}

int CTimer::start()
{
  startTime += (getRealTime() - pauseTime);
  running = true;
  return getTime();
}
