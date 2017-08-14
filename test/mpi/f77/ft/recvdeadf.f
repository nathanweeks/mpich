C -*- Mode: Fortran; -*- 

C  This test attempts MPI_Recv with the source being a dead process. It should fail
C  and return an error. If we are testing sufficiently new MPICH, we look for the
C  MPIX_ERR_PROC_FAILED error code. These should be converted to look for the
C  standarized error code once it is finalized.
C
      program main
      include "mpif.h"
      integer rank, size, err, errclass, ierr
      character*10 buf

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)
      if (size .lt. 2) then
         write(*,*) "Must run with at least 2 processes"
         call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
      end if

      if (rank .eq. 1) error stop "FORTRAN STOP"

      if (rank .eq. 0) then
         call MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN,
     &                               ierr)
         call MPI_Recv(buf, 1, MPI_CHARACTER, 1, 0, MPI_COMM_WORLD,
     &                 MPI_STATUS_IGNORE, err)
         call MPI_Error_class(err, errclass, ierr)
         if (errclass .eq. MPIX_ERR_PROC_FAILED) then
            write( *,*)" No Errors"
         else
            write(*,*) "Wrong error code (", errclass,
     &                 ") returned. Expected MPIX_ERR_PROC_FAILED"
         end if 
      end if
   
      call MPI_Finalize(ierr)

      end program