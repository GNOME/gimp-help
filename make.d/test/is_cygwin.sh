#!/bin/sh

type uname >/dev/null 2>&1 || exit 1
case `uname -s` in
	*[Cc][Yy][Gg][Ww][Ii][Nn]*)
		echo 1
		;;
	*)
		echo 0
		;;
esac

