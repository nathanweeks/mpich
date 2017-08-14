! -*- Mode: Fortran; -*- 

!
! This test attempts communication between 2 running processes
! after another process has failed.
!
      program main
      use mpi_f08
      implicit none
      integer rank, err, ierr
      type(MPI_Status) status
      character(len=10) buf

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
      call MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN, &
     &                             ierr)

      if (rank .eq. 1) error stop "FORTRAN STOP"

      if (rank .eq. 0) then
         call MPI_Send("No Errors ", 10, MPI_CHARACTER, 2, 0, &
     &                 MPI_COMM_WORLD, err)
         if (err .ne. 0) then
            write(*,*) "An error occurred during the send operation"
         end if
      end if

      if (rank .eq. 2) then
         call MPI_Recv(buf, 10, MPI_CHARACTER, 0, 0, MPI_COMM_WORLD, &
     &                 status, err)
         if (err .ne. 0) then
            write(*,*) "An error occurred during the recv operation"
         else
            write(*,*) buf
         end if
      end if

      call MPI_Finalize(ierr)

      end program